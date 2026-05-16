# Corresponding Source

MDPASTE Portable release `v0.1.0.0` redistributes upstream PasteMD `v0.1.6.8`.

The source published in this repository covers the visible modifications in this redistribution: modified upstream resource files, portable launcher scripts, configuration rewrite script, startup helper, packaging script, and documentation changes added for the portable release.

If the distributed `MdPaste.exe` contains Python logic changes beyond these visible resource changes, the corresponding modified Python source used to build that executable must also be added. The current local package does not expose those Python sources outside the PyInstaller executable.

Upstream corresponding source:

- Repository: https://github.com/RICHQAQ/PasteMD
- Tag: https://github.com/RICHQAQ/PasteMD/tree/v0.1.6.8
- Commit: `84b2cea1f291d910d4cf2d0a1fbc829f6bfec524`
- License: AGPL-3.0

Packaging source in this repository:

- `assets/icons/*`
- `pastemd/i18n/locales/*`
- `MDPASTE.cmd`
- `MdPaste-portable.cmd`
- `portable-config.ps1`
- `switch-startup.cmd`
- `build-release.ps1`

Detailed modifications from upstream are listed in `MODIFICATIONS.md`. The comparison against upstream `v0.1.6.8` is summarized in `UPSTREAM_COMPARISON.md`.

The release ZIP includes bundled third-party runtime files. Their license files are kept in place where provided by the upstream package, including Pandoc files under `_internal\pandoc\`.
