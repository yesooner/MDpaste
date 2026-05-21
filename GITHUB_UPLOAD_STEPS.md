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

Then commit:

```powershell
git add .gitattributes .gitignore LICENSE NOTICE.md SOURCE.md MDPASTE.cmd MdPaste-portable.cmd portable-config.ps1 switch-startup.cmd README.md README.txt RELEASE_NOTES.md build-release.ps1 GITHUB_UPLOAD_STEPS.md
git commit -m "Prepare PasteMD portable release"
```

## 3. Push to GitHub

Replace `<your-user>` and `<repo>` with your actual GitHub owner and repository name:

```powershell
git branch -M main
git remote add origin https://github.com/<your-user>/<repo>.git
git push -u origin main
```

## 4. Upload release assets

Open the repository on GitHub and create a new Release:

- Tag: `v0.1.1`
- Title: `MDPASTE Portable v0.1.1`
- Description: copy the content from `RELEASE_NOTES.md`

Upload these files as release assets:

- `dist\MDPASTE-portable-v0.1.1.zip`

Do not commit `_internal`, `MdPaste.exe`, `portable-data`, `cache`, or `dist` into the Git repository. They are ignored intentionally.

## 5. Test from GitHub

After the Release is published:

1. Download `MDPASTE-portable-v0.1.1.zip` from the Release page on another Windows computer.
2. Extract it.
3. Double-click `MDPASTE.cmd`.
4. Confirm that `portable-data\Roaming\PasteMD\config.json` is created and points to the extracted folder.
