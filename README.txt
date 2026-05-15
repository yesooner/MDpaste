MDPASTE Portable 使用说明
========================

首次使用：
1. 下载 MDPASTE-portable-v0.1.6.8.zip
2. 解压到任意文件夹
3. 双击 MDPASTE.cmd 启动
4. 复制 Markdown 内容后，按 Ctrl+Alt+B 使用

不要直接双击 MdPaste.exe。
请使用 MDPASTE.cmd，因为它会自动配置便携目录和当前电脑路径。

用途：
MDPASTE 用于把 AI 对话、网页、笔记或编辑器中复制出来的 Markdown 内容转换为更适合粘贴到 Word/WPS/Office 的格式。

便携路径：
程序会自动把配置写入 portable-data，并把 Pandoc 路径指向当前文件夹下的 _internal\pandoc\pandoc.exe。
移动到新电脑后仍然双击 MDPASTE.cmd 即可。

开机自启：
运行 switch-startup.cmd 启用或关闭。
移动文件夹后，请重新运行 switch-startup.cmd 更新路径。
