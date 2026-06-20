#define AppName "MDPASTE"
#ifndef AppVersion
#define AppVersion "0.1.8"
#endif
#define AppPublisher "yesooner"
#define AppExeName "MdPaste.exe"

[Setup]
AppId={{E3A35353-6A62-4F84-A674-3B4E6875A9C7}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
OutputDir=dist
OutputBaseFilename=MDPASTE-Setup-v{#AppVersion}
SetupIconFile=assets\icons\logo.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
UninstallDisplayIcon={app}\{#AppExeName}

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional tasks:"; Flags: unchecked
Name: "startup"; Description: "Start MDPASTE when Windows starts"; GroupDescription: "Additional tasks:"; Flags: unchecked

[Files]
Source: "MdPaste.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "_internal\*"; DestDir: "{app}\_internal"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "pastemd\*"; DestDir: "{app}\pastemd"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "i18n\*"; DestDir: "{app}\i18n"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "tools\*"; DestDir: "{app}\tools"; Excludes: "__pycache__\*,*.pyc"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "MDPASTE.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "MdPaste-portable-launcher.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "MdPaste-portable.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "portable-config.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "switch-startup.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "RELEASE_NOTES.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "MODIFICATIONS.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "UPSTREAM_COMPARISON.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "SOURCE.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "NOTICE.md"; DestDir: "{app}"; Flags: ignoreversion

[Dirs]
Name: "{app}\cache"
Name: "{app}\portable-data\Roaming"
Name: "{app}\portable-data\Local"

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\MdPaste-portable-launcher.exe"; WorkingDir: "{app}"; IconFilename: "{app}\assets\icons\logo.ico"
Name: "{group}\Uninstall {#AppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\MdPaste-portable-launcher.exe"; WorkingDir: "{app}"; IconFilename: "{app}\assets\icons\logo.ico"; Tasks: desktopicon
Name: "{userstartup}\{#AppName}"; Filename: "{app}\MdPaste-portable-launcher.exe"; WorkingDir: "{app}"; IconFilename: "{app}\assets\icons\logo.ico"; Tasks: startup

[Run]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\portable-config.ps1"" -HomeDir ""{app}"""; Flags: runhidden waituntilterminated
Filename: "{app}\MdPaste-portable-launcher.exe"; Description: "Launch {#AppName}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "taskkill.exe"; Parameters: "/F /IM MdPaste.exe"; Flags: runhidden; RunOnceId: "StopMdPaste"
