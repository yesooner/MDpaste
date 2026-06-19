# GitHub Upload Steps

## 1. Create the GitHub repository

Create a new repository on GitHub, for example:

- Repository name: `PasteMD-portable`
- Visibility: public or private
- Do not initialize with README, `.gitignore`, or license because this folder already has them.

## 2. Commit the repository files

Configure your Git author identity once if needed:

```powershell
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Then commit the maintained source, launcher, packaging, and documentation files:

```powershell
git add .gitattributes .gitignore LICENSE NOTICE.md SOURCE.md MDPASTE.cmd MdPaste-portable.cmd portable-config.ps1 switch-startup.cmd README.md i18n RELEASE_NOTES.md MODIFICATIONS.md UPSTREAM_COMPARISON.md build-release.ps1 GITHUB_UPLOAD_STEPS.md tools tests
git commit -m "fix: 更新便携启动和复制清理"
```

Do not commit `_internal`, `MdPaste.exe`, `portable-data`, `cache`, generated backups, or `dist`; they are intentionally ignored.

## 3. Build the release ZIP

Build the native no-console launcher first if needed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_portable_launcher.ps1
```

Then build the portable ZIP:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\build-release.ps1
```

The ZIP should include `MdPaste-portable-launcher.exe`; users should start from that file.

## 4. Push to GitHub

Replace `<your-user>` and `<repo>` with the actual GitHub owner and repository name:

```powershell
git branch -M main
git remote add origin https://github.com/<your-user>/<repo>.git
git push -u origin main
```

## 5. Upload release assets

Open the repository on GitHub and create a new Release:

- Tag: `v0.1.1`
- Title: `MDPASTE Portable v0.1.1`
- Description: copy the content from `RELEASE_NOTES.md`

Upload this file as the release asset:

- `dist\MDPASTE-portable-v0.1.1.zip`

## 6. Test from GitHub

After the Release is published:

1. Download `MDPASTE-portable-v0.1.1.zip` from the Release page on another Windows computer.
2. Extract it.
3. Double-click `MdPaste-portable-launcher.exe`.
4. Confirm that `portable-data\Roaming\PasteMD\config.json` is created and points to the extracted folder.
