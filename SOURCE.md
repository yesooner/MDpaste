# Corresponding Source

This portable package redistributes PasteMD `v0.1.6.8`.

This redistribution does not modify the upstream `MdPaste.exe` binary. The source published in this repository covers the portable launcher, configuration rewrite script, startup helper, packaging script, and documentation changes added for the portable release.

Upstream corresponding source:

- Repository: https://github.com/RICHQAQ/PasteMD
- Tag: https://github.com/RICHQAQ/PasteMD/tree/v0.1.6.8
- Commit: `84b2cea1f291d910d4cf2d0a1fbc829f6bfec524`
- License: AGPL-3.0

Packaging source in this repository:

- `MdPaste-portable.cmd`
- `portable-config.ps1`
- `switch-startup.cmd`
- `build-release.ps1`

The release ZIP includes bundled third-party runtime files. Their license files are kept in place where provided by the upstream package, including Pandoc files under `_internal\pandoc\`.
