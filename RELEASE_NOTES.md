# MDPASTE Portable v0.1.8

## Assets

- `MDPASTE-portable-v0.1.8.zip`: portable package. Extract and start `MdPaste-portable-launcher.exe`. This ZIP includes `MdPaste.exe`.
- `MDPASTE-Setup-v0.1.8.exe`: optional Windows installer built with Inno Setup. The installer also includes `MdPaste.exe`.

## What Changed

- Added a reproducible Inno Setup installer build using `installer.iss` and `build-installer.ps1`.
- Added the local Inno Setup compiler search path `F:\InnoSetup6\ISCC.exe`.
- Included installer build scripts in the portable ZIP so another machine can rebuild the same package when Inno Setup is installed.
- Kept the executable compatibility fixes for ChatGPT fragment copy, fenced code blocks, inline code, and LaTeX/formula handling.

## v0.1.8 Compatibility Fixes Kept

- ChatGPT web fragment copy prefers clipboard HTML when plaintext content has already lost Markdown fences.
- Fenced code blocks, indented code blocks, and inline code are protected from LaTeX/formula rewrites.
- Normal body formula conversion remains enabled for copied Markdown and web fragments.
- `tools/patch_release_exe.py` remains the corresponding patch script used to update the bundled PyInstaller executable.

## Portability Check

- Startup still derives the app home from `MdPaste-portable-launcher.exe`; no local machine path is required.
- `portable-config.ps1` rewrites `pandoc_path` and `save_dir` from the current folder on every start.
- Runtime state remains under `portable-data` and `cache`, so the extracted folder can be copied to another Windows computer.

## Versioning

This project should use SemVer-style release names going forward:

- Patch fixes: `0.1.7.1`, `0.1.8`
- New compatible features: `0.2.0`
- Stable public release: `1.0.0`

## User Notes

- First run: extract the ZIP, then double-click `MdPaste-portable-launcher.exe`.
- Do not run `MdPaste.exe` directly.
- The portable launcher rewrites `pandoc_path` and `save_dir` for the current computer on every start without opening a command prompt.
- Bundled Pandoc is required and included under `_internal\pandoc\pandoc.exe`.
- Local user config/log/cache files are not included in the clean release package.
- If startup on login is enabled and the folder is moved, run `switch-startup.cmd` again.

## Purpose

MDPASTE converts copied Markdown, including AI chat answers, into formatted paste output for Word/WPS/Office and other supported applications.

## License and Source

- Upstream project: <https://github.com/RICHQAQ/PasteMD>
- Portable release version: `v0.1.8`
- Upstream corresponding source: <https://github.com/RICHQAQ/PasteMD/tree/v0.1.6.8>
- License: AGPL-3.0. The release keeps `LICENSE`, `NOTICE.md`, and `SOURCE.md`.
