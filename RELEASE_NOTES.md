# MDPASTE Portable v0.1.0.0

## Assets

- `MDPASTE-portable-v0.1.0.0.zip`: portable package. Extract and run `MDPASTE.cmd`.

## User Notes

- First run: extract the ZIP, then double-click `MDPASTE.cmd`.
- Do not run `MdPaste.exe` directly.
- The portable launcher rewrites `pandoc_path` and `save_dir` for the current computer on every start.
- Bundled Pandoc is required and included under `_internal\pandoc\pandoc.exe`.
- Local user config/log/cache files are not included in the clean release package.
- If startup on login is enabled and the folder is moved, run `switch-startup.cmd` again.

## Purpose

MDPASTE converts copied Markdown, including AI chat answers, into formatted paste output for Word/WPS/Office and other supported applications.

## Source Compliance

This release does not modify the upstream `MdPaste.exe` binary. The repository publishes the portable launcher, configuration, packaging scripts, and documentation changes made for this redistribution. Upstream corresponding source is linked below.

Detailed changes from upstream are documented in `MODIFICATIONS.md`.

## License and Source

- Upstream project: <https://github.com/RICHQAQ/PasteMD>
- Portable release version: `v0.1.0.0`
- Upstream corresponding source: <https://github.com/RICHQAQ/PasteMD/tree/v0.1.6.8>
- License: AGPL-3.0. The release keeps `LICENSE`, `NOTICE.md`, and `SOURCE.md`.
