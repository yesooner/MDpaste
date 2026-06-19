import unittest
import re
import marshal
import tempfile
import zlib
from pathlib import Path

from tools import patch_release_exe as patcher
from tools.patch_release_exe import (
    PATCHED_CONVERT_LATEX_SOURCE,
    PYZ_MAGIC,
    write_pyz,
    read_pyz,
)


def load_convert_latex_delimiters():
    namespace = {}

    def identity(text):
        return text

    namespace.update(
        {
            "_unwrap_blockquoted_math": identity,
            "_convert_bare_bracket_display_math": identity,
            "_convert_standard_latex_delimiters": identity,
            "_fix_inline_math_spaces": identity,
            "_fix_single_dollar_blocks": identity,
            "_normalize_inline_math_segments": identity,
            "_normalize_display_math_blocks": identity,
            "re": re,
        }
    )
    exec(PATCHED_CONVERT_LATEX_SOURCE, namespace)
    return namespace["convert_latex_delimiters"]


class FenceInfoCleanupTests(unittest.TestCase):
    def setUp(self):
        self.convert = load_convert_latex_delimiters()

    def test_removes_double_quoted_id_from_python_fence(self):
        markdown = '```python id="c2m9kk"\nprint("ok")\n```\n'

        result = self.convert(markdown)

        self.assertEqual(result, '```python\nprint("ok")\n```\n')
        self.assertNotIn("id=", result.splitlines()[0])

    def test_removes_id_from_text_and_other_language_fences(self):
        cases = [
            ("```text id='c2m9kk'\nhello\n```\n", "```text\nhello\n```\n"),
            ("```javascript id=c2m9kk\nconsole.log(1)\n```\n", "```javascript\nconsole.log(1)\n```\n"),
            ("```python id\nprint(1)\n```\n", "```python\nprint(1)\n```\n"),
            ("```python #c2m9kk\nprint(1)\n```\n", "```python\nprint(1)\n```\n"),
            ("~~~~python id=\"c2m9kk\"\nprint(1)\n~~~~\n", "~~~~python\nprint(1)\n~~~~\n"),
        ]

        for markdown, expected in cases:
            with self.subTest(markdown=markdown):
                self.assertEqual(self.convert(markdown), expected)

    def test_removes_markdown_attribute_id_from_fence_info(self):
        cases = [
            ("```python {#c2m9kk}\nprint(1)\n```\n", "```python\nprint(1)\n```\n"),
            ("```python {.numberLines #c2m9kk}\nprint(1)\n```\n", "```python {.numberLines}\nprint(1)\n```\n"),
            ("```python {id=\"c2m9kk\" .numberLines}\nprint(1)\n```\n", "```python {.numberLines}\nprint(1)\n```\n"),
            ("```python {id = \"c2m9kk\" .numberLines}\nprint(1)\n```\n", "```python {.numberLines}\nprint(1)\n```\n"),
            ("```python {id .numberLines}\nprint(1)\n```\n", "```python {.numberLines}\nprint(1)\n```\n"),
            ("```python {id = \"c2m9kk\" caption=\"two words\"}\nprint(1)\n```\n", "```python {caption=\"two words\"}\nprint(1)\n```\n"),
            ("```python data-id=\"keep\" id=\"drop\"\nprint(1)\n```\n", "```python data-id=\"keep\"\nprint(1)\n```\n"),
        ]

        for markdown, expected in cases:
            with self.subTest(markdown=markdown):
                self.assertEqual(self.convert(markdown), expected)

    def test_promotes_pandoc_language_class_to_fence_language(self):
        cases = [
            ("```{.python #c2m9kk}\nprint(1)\n```\n", "```python\nprint(1)\n```\n"),
            ("```{#c2m9kk .javascript}\nconsole.log(1)\n```\n", "```javascript\nconsole.log(1)\n```\n"),
            ("```{.python .numberLines #c2m9kk}\nprint(1)\n```\n", "```python {.numberLines}\nprint(1)\n```\n"),
            ("```{.numberLines #c2m9kk}\nprint(1)\n```\n", "```{.numberLines}\nprint(1)\n```\n"),
            ("```.python #c2m9kk\nprint(1)\n```\n", "```python\nprint(1)\n```\n"),
            ("~~~.javascript #c2m9kk\nconsole.log(1)\n~~~\n", "~~~javascript\nconsole.log(1)\n~~~\n"),
        ]

        for markdown, expected in cases:
            with self.subTest(markdown=markdown):
                self.assertEqual(self.convert(markdown), expected)

    def test_preserves_code_content_ids(self):
        markdown = '```python id="outer"\nprint(\'id="inner"\')\n```\n'

        result = self.convert(markdown)

        self.assertEqual(result, "```python\nprint('id=\"inner\"')\n```\n")

    def test_chinese_text_fence_gets_plain_text_normalization(self):
        markdown = "```文字\n hello\n```\n"

        result = self.convert(markdown)

        self.assertEqual(result, "```文字\nhello\n```\n")


class PyzWriterTests(unittest.TestCase):
    def test_write_pyz_creates_missing_parent_directory(self):
        raw_code = compile("VALUE = 1\n", "sample.py", "exec")
        compressed = zlib.compress(marshal.dumps(raw_code), 6)
        original_data = bytearray(b"\0" * 17)
        offset = len(original_data)
        original_data.extend(compressed)
        toc = [("sample", (0, offset, len(compressed)))]

        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / "missing" / "PYZ.pyz"

            write_pyz(output, b"\xf3\r\r\n", bytes(original_data), toc, {})

            data, py_magic, written_toc = read_pyz(output)
            self.assertEqual(data[:4], PYZ_MAGIC)
            self.assertEqual(py_magic, b"\xf3\r\r\n")
            self.assertEqual(written_toc[0][0], "sample")


class PythonMagicGuardTests(unittest.TestCase):
    def test_rejects_pyz_magic_that_does_not_match_runtime(self):
        checker = getattr(patcher, "ensure_runtime_magic_matches_pyz", None)
        self.assertIsNotNone(checker, "patch script must guard against wrong Python versions")

        with self.assertRaisesRegex(RuntimeError, "Python bytecode magic mismatch"):
            checker(b"\x00\x00\x00\x00", runtime_magic=b"\xf3\r\r\n")


class RunningExeGuardTests(unittest.TestCase):
    def test_rejects_patching_same_running_exe_path(self):
        checker = getattr(patcher, "ensure_exe_not_running", None)
        self.assertIsNotNone(checker, "patch script must refuse to patch a running exe")

        with tempfile.TemporaryDirectory() as tmp:
            exe = Path(tmp) / "MdPaste.exe"
            exe.write_bytes(b"placeholder")

            with self.assertRaisesRegex(RuntimeError, "MdPaste.exe is currently running"):
                checker(exe, running_paths=[str(exe)])

    def test_allows_different_running_mdpaste_path(self):
        checker = getattr(patcher, "ensure_exe_not_running", None)
        self.assertIsNotNone(checker, "patch script must refuse to patch a running exe")

        with tempfile.TemporaryDirectory() as tmp:
            exe = Path(tmp) / "target" / "MdPaste.exe"
            other = Path(tmp) / "other" / "MdPaste.exe"
            exe.parent.mkdir()
            other.parent.mkdir()
            exe.write_bytes(b"target")
            other.write_bytes(b"other")

            checker(exe, running_paths=[str(other)])


class ExeBackupTests(unittest.TestCase):
    def test_create_exe_backups_preserves_original_and_creates_timestamped_copy(self):
        create_backups = getattr(patcher, "create_exe_backups", None)
        self.assertIsNotNone(create_backups, "patch script must create per-run backups")

        with tempfile.TemporaryDirectory() as tmp:
            exe = Path(tmp) / "MdPaste.exe"
            exe.write_bytes(b"current exe")
            original_backup = Path(tmp) / "MdPaste.exe.before-codeblock-patch"
            original_backup.write_bytes(b"first backup")

            backups = create_backups(exe, timestamp="20260620-020000")

            timestamped_backup = Path(tmp) / "MdPaste.exe.before-patch-20260620-020000"
            self.assertEqual(original_backup.read_bytes(), b"first backup")
            self.assertEqual(timestamped_backup.read_bytes(), b"current exe")
            self.assertIn(timestamped_backup, backups)

    def test_create_exe_backups_uses_suffix_when_timestamped_backup_exists(self):
        create_backups = getattr(patcher, "create_exe_backups", None)
        self.assertIsNotNone(create_backups, "patch script must create per-run backups")

        with tempfile.TemporaryDirectory() as tmp:
            exe = Path(tmp) / "MdPaste.exe"
            exe.write_bytes(b"current exe")
            existing_backup = Path(tmp) / "MdPaste.exe.before-patch-20260620-020000"
            existing_backup.write_bytes(b"previous exe")

            backups = create_backups(exe, timestamp="20260620-020000")

            suffixed_backup = Path(tmp) / "MdPaste.exe.before-patch-20260620-020000-1"
            self.assertEqual(existing_backup.read_bytes(), b"previous exe")
            self.assertEqual(suffixed_backup.read_bytes(), b"current exe")
            self.assertIn(suffixed_backup, backups)


class AppVersionPatchTests(unittest.TestCase):
    def test_patch_script_updates_embedded_app_version_constant(self):
        APP_VERSION_OLD = getattr(patcher, "APP_VERSION_OLD", None)
        APP_VERSION_NEW = getattr(patcher, "APP_VERSION_NEW", None)

        self.assertEqual(APP_VERSION_OLD, "0.1.6.9rc1")
        self.assertEqual(APP_VERSION_NEW, "0.1.8")

        raw_code = compile('VERSION = "0.1.6.9rc1"\n', "pastemd/__init__.py", "exec")
        patched, changed = patcher.replace_const(raw_code, APP_VERSION_OLD, APP_VERSION_NEW)

        self.assertTrue(changed)
        self.assertIn(APP_VERSION_NEW, patched.co_consts)
        self.assertNotIn(APP_VERSION_OLD, patched.co_consts)


if __name__ == "__main__":
    unittest.main()
