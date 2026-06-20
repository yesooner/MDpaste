from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class PortableLauncherTests(unittest.TestCase):
    def test_launcher_skips_powershell_when_portable_home_marker_matches(self):
        launcher = (ROOT / "MdPaste-portable.cmd").read_text(encoding="utf-8")

        self.assertIn("MARKER_PATH", launcher)
        self.assertIn("NEEDS_CONFIG", launcher)
        self.assertIn("set /p CONFIG_HOME=", launcher)
        self.assertIn("goto launch_app", launcher.lower())
        self.assertLess(launcher.lower().count("powershell "), 2)

    def test_launcher_exits_when_mdpaste_is_already_running(self):
        launcher = (ROOT / "MdPaste-portable.cmd").read_text(encoding="utf-8").lower()

        self.assertIn("mdpaste-portable-launcher.exe", launcher)
        self.assertNotIn("tasklist", launcher)
        self.assertNotIn("find /i", launcher)
        self.assertIn("already running", launcher)
        self.assertIn("exit /b 0", launcher)

    def test_native_launcher_has_reproducible_build_script(self):
        script = (ROOT / "tools" / "build_portable_launcher.ps1").read_text(encoding="utf-8")

        self.assertIn("MdPastePortableLauncher.cs", script)
        self.assertIn("MdPaste-portable-launcher.exe", script)
        self.assertIn("[string]$RootDir = (Split-Path -Parent $PSScriptRoot)", script)
        self.assertNotIn("Split-Path -Parent (Split-Path -Parent $PSScriptRoot)", script)
        self.assertIn("Framework64\\v4.0.30319\\csc.exe", script)
        self.assertIn("/target:winexe", script)
        self.assertIn("/reference:System.Web.Extensions.dll", script)
        self.assertIn("/reference:System.Windows.Forms.dll", script)

    def test_release_package_script_includes_native_launcher_and_ignores_runtime_state(self):
        release_script_path = ROOT / "build-release.ps1"
        gitignore_path = ROOT / ".gitignore"

        self.assertTrue(release_script_path.exists(), "build-release.ps1 must exist")
        self.assertTrue(gitignore_path.exists(), ".gitignore must exist")

        release_script = release_script_path.read_text(encoding="utf-8")
        gitignore = gitignore_path.read_text(encoding="utf-8")

        self.assertIn('"MdPaste-portable-launcher.exe"', release_script)
        self.assertIn('"tools"', release_script)
        self.assertIn("__pycache__", release_script)
        self.assertIn("*.pyc", release_script)
        self.assertIn("MdPaste.exe.before-*", gitignore)
        self.assertIn("exe-extract-tmp/", gitignore)
        self.assertIn("portable-data/", gitignore)
        self.assertIn("_internal/", gitignore)

    def test_native_launcher_checks_running_app_without_external_query_processes(self):
        source = (ROOT / "tools" / "MdPastePortableLauncher.cs").read_text(encoding="utf-8").lower()

        self.assertIn('getprocessesbyname("mdpaste")', source)
        self.assertIn("mainmodule.filename", source)
        self.assertIn("useshellexecute = false", source)
        self.assertNotIn("tasklist", source)
        self.assertNotIn("powershell", source)

    def test_startup_task_uses_native_launcher_without_cmd_host(self):
        script = (ROOT / "switch-startup.cmd").read_text(encoding="utf-8").lower()

        self.assertIn("mdpaste-portable-launcher.exe", script)
        self.assertNotIn("mdpaste-portable.cmd", script)

    def test_release_docs_recommend_native_launcher_as_user_entry(self):
        docs = "\n".join(
            [
                (ROOT / "README.md").read_text(encoding="utf-8"),
                (ROOT / "i18n" / "README.en.md").read_text(encoding="utf-8"),
                (ROOT / "RELEASE_NOTES.md").read_text(encoding="utf-8"),
                (ROOT / "MODIFICATIONS.md").read_text(encoding="utf-8"),
                (ROOT / "UPSTREAM_COMPARISON.md").read_text(encoding="utf-8"),
                (ROOT / "SOURCE.md").read_text(encoding="utf-8"),
            ]
        )

        self.assertIn("MdPaste-portable-launcher.exe", docs)
        self.assertNotIn("Double-click `MDPASTE.cmd`", docs)
        self.assertNotIn("run `MDPASTE.cmd`", docs)
        self.assertNotIn("pointing to the current folder's `MdPaste-portable.cmd`", docs)

    def test_github_upload_steps_use_current_launcher_and_package_contents(self):
        steps_path = ROOT / "GITHUB_UPLOAD_STEPS.md"

        self.assertTrue(steps_path.exists(), "GITHUB_UPLOAD_STEPS.md must exist")
        steps = steps_path.read_text(encoding="utf-8")
        self.assertIn("MdPaste-portable-launcher.exe", steps)
        self.assertNotIn("Double-click `MDPASTE.cmd`", steps)
        self.assertNotIn("README.md i18n README.md", steps)
        self.assertIn("README.md i18n RELEASE_NOTES.md", steps)

    def test_modifications_markdown_has_normal_top_level_bullets(self):
        modifications = (ROOT / "MODIFICATIONS.md").read_text(encoding="utf-8")

        self.assertNotIn("\n - `tools/MdPastePortableLauncher.cs`", modifications)
        self.assertNotIn("\n - `tools/build_portable_launcher.ps1`", modifications)

    def test_release_metadata_uses_current_patch_version(self):
        docs = "\n".join(
            [
                (ROOT / "README.md").read_text(encoding="utf-8"),
                (ROOT / "i18n" / "README.en.md").read_text(encoding="utf-8"),
                (ROOT / "RELEASE_NOTES.md").read_text(encoding="utf-8"),
                (ROOT / "MODIFICATIONS.md").read_text(encoding="utf-8"),
                (ROOT / "UPSTREAM_COMPARISON.md").read_text(encoding="utf-8"),
                (ROOT / "SOURCE.md").read_text(encoding="utf-8"),
                (ROOT / "GITHUB_UPLOAD_STEPS.md").read_text(encoding="utf-8"),
                (ROOT / "build-release.ps1").read_text(encoding="utf-8"),
            ]
        )

        self.assertIn("MDPASTE-portable-v0.1.8.zip", docs)
        self.assertIn("MDPASTE Portable v0.1.8", docs)
        self.assertIn('[string]$Version = "0.1.8"', docs)
        self.assertNotIn("MDPASTE-portable-v0.1.2.zip", docs)
        self.assertNotIn("Portable release version: `v0.1.2`", docs)
        self.assertNotIn("MDPASTE-portable-v0.1.7.2.zip", docs)

    def test_native_launcher_exits_before_touching_config_when_app_is_running(self):
        source = (ROOT / "tools" / "MdPastePortableLauncher.cs").read_text(encoding="utf-8")

        running_check = source.index("IsSameMdPasteRunning(appExe)")
        configure_call = source.index("ConfigurePortableHome(home)")
        self.assertLess(running_check, configure_call)

    def test_native_launcher_skips_config_file_write_when_marker_matches(self):
        source = (ROOT / "tools" / "MdPastePortableLauncher.cs").read_text(encoding="utf-8")

        self.assertIn("NeedsPortableConfigRefresh", source)
        self.assertIn("if (!NeedsPortableConfigRefresh(configPath, markerPath, home, pandocPath, cacheDir))", source)
        self.assertIn("return;", source[source.index("if (!NeedsPortableConfigRefresh") :])

    def test_native_launcher_refreshes_config_when_portable_paths_drift(self):
        source = (ROOT / "tools" / "MdPastePortableLauncher.cs").read_text(encoding="utf-8")

        self.assertIn("NeedsPortableConfigRefresh(configPath, markerPath, home, pandocPath, cacheDir)", source)
        self.assertIn('"pandoc_path"', source)
        self.assertIn('"save_dir"', source)
        self.assertIn("ConfigValueMatches", source)

    def test_portable_config_defaults_disable_windows_notifications(self):
        launcher = (ROOT / "tools" / "MdPastePortableLauncher.cs").read_text(encoding="utf-8")
        script = (ROOT / "portable-config.ps1").read_text(encoding="utf-8")

        self.assertIn('config["notify"] = false;', launcher)
        self.assertIn('config["startup_notify"] = false;', launcher)
        self.assertIn('Set-JsonProperty $config "notify" $false', script)
        self.assertIn('Set-JsonProperty $config "startup_notify" $false', script)

    def test_native_launcher_refreshes_config_when_notifications_are_enabled(self):
        source = (ROOT / "tools" / "MdPastePortableLauncher.cs").read_text(encoding="utf-8")

        self.assertIn("ConfigBoolMatches", source)
        self.assertIn('ConfigBoolMatches(config, "notify", false)', source)
        self.assertIn('ConfigBoolMatches(config, "startup_notify", false)', source)

    def test_portable_config_writes_home_marker(self):
        script = (ROOT / "portable-config.ps1").read_text(encoding="utf-8")

        self.assertIn(".portable-home", script)
        self.assertIn("WriteAllText($markerPath, $homePath", script)


if __name__ == "__main__":
    unittest.main()
