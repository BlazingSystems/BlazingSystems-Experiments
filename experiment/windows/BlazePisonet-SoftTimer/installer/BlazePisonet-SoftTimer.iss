#define MyAppName "BlazePisonet SoftTimer"
#define MyAppPublisher "BlazeSystems"
#ifndef AppVersion
  #define AppVersion "0.2.0"
#endif
#ifndef AppSource
  #define AppSource "."
#endif
#ifndef OutputDir
  #define OutputDir "."
#endif

[Setup]
AppId={{7B9E6674-0E93-45A0-BEF4-779A6418FA7C}
AppName={#MyAppName}
AppVersion={#AppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL=https://github.com/BlazingSystems/BlazingSystems-Experiments
DefaultDirName={autopf}\BlazeSystems\BlazePisonet SoftTimer
DefaultGroupName=BlazePisonet SoftTimer
DisableProgramGroupPage=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
OutputDir={#OutputDir}
OutputBaseFilename=BlazePisonet-SoftTimer-Setup-v{#AppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
SetupLogging=yes
CloseApplications=yes
RestartApplications=no
UninstallDisplayName=BlazePisonet SoftTimer
UninstallDisplayIcon={app}\BlazePisonet.SoftTimer.exe
MinVersion=10.0.17763

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Files]
Source: "{#AppSource}\BlazePisonet.SoftTimer.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#AppSource}\BlazePisonet.SoftTimer.Watchdog.exe"; DestDir: "{app}"; Flags: ignoreversion

[Dirs]
Name: "{commonappdata}\BlazeSystems\BlazePisonetSoftTimer"; Permissions: admins-full system-full

[Icons]
Name: "{group}\BlazePisonet SoftTimer"; Filename: "{app}\BlazePisonet.SoftTimer.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\BlazePisonet SoftTimer"; Filename: "{app}\BlazePisonet.SoftTimer.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\BlazePisonet.SoftTimer.exe"; Description: "Launch BlazePisonet SoftTimer"; WorkingDir: "{app}"; Flags: nowait postinstall skipifsilent

[Code]
procedure RunHidden(const FileName, Params: string);
var
  ResultCode: Integer;
begin
  Log('Executing: ' + FileName + ' ' + Params);
  if not Exec(FileName, Params, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    Log('Could not execute ' + FileName)
  else
    Log('Exit code: ' + IntToStr(ResultCode));
end;

procedure DeleteIfExists(const FileName: string);
begin
  if FileExists(FileName) then
    DeleteFile(FileName);
end;

procedure ConfigureSystem;
var
  AppExe, WatchdogExe, DataDir: string;
begin
  AppExe := ExpandConstant('{app}\BlazePisonet.SoftTimer.exe');
  WatchdogExe := ExpandConstant('{app}\BlazePisonet.SoftTimer.Watchdog.exe');
  DataDir := ExpandConstant('{commonappdata}\BlazeSystems\BlazePisonetSoftTimer');

  DeleteIfExists(DataDir + '\maintenance.until');

  RunHidden(ExpandConstant('{sys}\schtasks.exe'),
    '/Delete /TN "BlazePisonet SoftTimer" /F');
  RunHidden(ExpandConstant('{sys}\schtasks.exe'),
    '/Delete /TN "BlazePisonet SoftTimer Watchdog" /F');

  RunHidden(ExpandConstant('{sys}\schtasks.exe'),
    '/Create /TN "BlazePisonet SoftTimer" /SC ONLOGON /TR "' + AppExe + '" /RL HIGHEST /F');
  RunHidden(ExpandConstant('{sys}\schtasks.exe'),
    '/Create /TN "BlazePisonet SoftTimer Watchdog" /SC ONLOGON /TR "' + WatchdogExe + '" /RL HIGHEST /F');

  RunHidden(ExpandConstant('{sys}\netsh.exe'),
    'advfirewall firewall delete rule name="BlazePisonet SoftTimer Centralized"');
  RunHidden(ExpandConstant('{sys}\netsh.exe'),
    'advfirewall firewall add rule name="BlazePisonet SoftTimer Centralized" dir=in action=allow protocol=TCP localport=8765 remoteip=LocalSubnet profile=private');
end;

procedure PrepareUninstall;
var
  DataDir: string;
begin
  DataDir := ExpandConstant('{commonappdata}\BlazeSystems\BlazePisonetSoftTimer');
  ForceDirectories(DataDir);
  SaveStringToFile(DataDir + '\maintenance.until', '4102444800', False);

  RunHidden(ExpandConstant('{sys}\schtasks.exe'),
    '/Delete /TN "BlazePisonet SoftTimer" /F');
  RunHidden(ExpandConstant('{sys}\schtasks.exe'),
    '/Delete /TN "BlazePisonet SoftTimer Watchdog" /F');
  RunHidden(ExpandConstant('{sys}\netsh.exe'),
    'advfirewall firewall delete rule name="BlazePisonet SoftTimer Centralized"');
  RunHidden(ExpandConstant('{sys}\taskkill.exe'),
    '/IM BlazePisonet.SoftTimer.Watchdog.exe /F');
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    ConfigureSystem;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
    PrepareUninstall;
end;
