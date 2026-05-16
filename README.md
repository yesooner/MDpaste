# MDPASTE Portable

MDPASTE Portable 是基于上游 PasteMD 制作的 Windows 便携版封装，用于把复制出来的 Markdown 内容转换成更适合粘贴到 Word、WPS、Office 等软件中的格式。

常见使用场景：从 AI 对话中复制回答内容，例如标题、列表、代码块、表格、公式等 Markdown 文本，然后通过 MDPASTE 转换并粘贴到文档里，减少手动排版。

本便携包已经内置 Pandoc，使用者不需要单独安装 Python、Pandoc 或其他命令行工具。

## 首次使用

1. 在 GitHub Releases 页面下载 `MDPASTE-portable-v0.1.0.0.zip`。
2. 解压到任意文件夹。
3. 双击 `MDPASTE.cmd` 启动。
4. 复制 Markdown 内容。
5. 按默认快捷键 `Ctrl+Alt+B` 进行转换/粘贴。

不要直接双击 `MdPaste.exe`。请使用 `MDPASTE.cmd`，因为它会先准备便携数据目录，并按当前电脑路径自动写入配置。

## 文件说明

- `MDPASTE.cmd`：普通用户启动入口，双击这个文件。
- `MdPaste-portable.cmd`：实际便携启动脚本，负责设置路径和检查依赖。
- `MdPaste.exe`：上游 PasteMD 主程序，不建议直接双击。
- `_internal\pandoc\pandoc.exe`：内置 Pandoc，用于文档和富文本转换。
- `switch-startup.cmd`：开机自启启用/关闭工具。
- `portable-data`：本机配置和日志目录，首次运行后自动创建。
- `cache`：转换缓存目录，首次运行后自动创建。

## 路径和移植

可以直接移植到新电脑。每次从 `MDPASTE.cmd` 启动时，程序都会按当前文件夹重写配置：

- `APPDATA` -> `portable-data\Roaming`
- `LOCALAPPDATA` -> `portable-data\Local`
- `pandoc_path` -> 当前文件夹下的 `_internal\pandoc\pandoc.exe`
- `save_dir` -> 当前文件夹下的 `cache`

所以把整个文件夹复制到另一台 Windows 电脑后，仍然双击 `MDPASTE.cmd` 即可，不需要手动修改路径。

## Pandoc 使用

PasteMD 的文档/富文本转换依赖 Pandoc。本便携包已经把 Pandoc 放在：

```text
_internal\pandoc\pandoc.exe
```

不要删除 `_internal` 目录。如果 Pandoc 缺失，启动脚本会停止并提示重新下载完整 ZIP。

## 开机自启

运行 `switch-startup.cmd`，按提示启用或关闭开机自启。

如果移动了文件夹，请重新运行一次 `switch-startup.cmd`，让 Windows 计划任务更新到新的路径。

## 本地数据

这些文件会在使用者电脑上自动生成：

- 配置文件：`portable-data\Roaming\PasteMD\config.json`
- 日志文件：`portable-data\Roaming\PasteMD\pastemd.log`
- 缓存目录：`cache`

这些是本机运行数据，不提交到 Git，也不会打入干净的发布 ZIP。

## 版本维护

如果发行版本发生变化，需要同步修改以下位置：

- `README.md` 和 `README.txt` 中的下载文件名。
- `RELEASE_NOTES.md` 中的版本号和附件名。
- `SOURCE.md` 中对应的上游 tag、commit 和源码链接。
- `build-release.ps1` 中的默认 `$Version`。
- Git tag，例如 `v0.1.0.0`。
- GitHub Release 标题、说明和附件 ZIP 名称。

版本号不一致会导致用户下载说明、Release 附件和源码说明互相对不上，所以每次发布新版本都应统一检查。

## 仓库和发布方式

Git 仓库只保存启动脚本、打包脚本、说明文档、许可证和源码说明。完整可运行包通过 GitHub Release 附件发布。

本地生成发布 ZIP：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\build-release.ps1
```

输出文件：

```text
dist\MDPASTE-portable-v0.1.0.0.zip
```

## Codex 声明

本仓库中的便携启动脚本、路径配置脚本、打包脚本、README、Release notes、NOTICE 和 SOURCE 说明由 OpenAI Codex 在与项目维护者的对话过程中辅助撰写和整理。

上游 PasteMD 程序本体不属于 Codex 创作内容。本仓库未修改上游 `MdPaste.exe` 二进制文件。

## 相对上游的修改

本仓库没有修改上游 `MdPaste.exe` 二进制文件，也没有在仓库中提交上游源码补丁。

本仓库新增的是便携封装相关内容，包括 `MDPASTE.cmd`、`MdPaste-portable.cmd`、`portable-config.ps1`、`switch-startup.cmd`、`build-release.ps1` 以及说明和许可文件。详细修改清单见 `MODIFICATIONS.md`。

## 上游项目和许可

上游项目：<https://github.com/RICHQAQ/PasteMD>

本便携封装发行版本为 `v0.1.0.0`。它重新分发的上游 PasteMD 对应版本为 `v0.1.6.8`：<https://github.com/RICHQAQ/PasteMD/tree/v0.1.6.8>

PasteMD 采用 AGPL-3.0 许可。本仓库是对 PasteMD Windows 便携包的再分发/封装，仓库内启动脚本和打包文件也按 AGPL-3.0 发布。发布时请保留 `LICENSE`、`NOTICE.md` 和 `SOURCE.md`。
