#define MyAppName "BlazePisonet SoftTimer"
#define MyAppPublisher "BlazeSystems"
#ifndef AppVersion
  #define AppVersion "0.2.0"
#endif
#ifndef AppSource
  #define AppSource "..\\..\\..\\..\\out\\bundle"
#endif
#ifndef OutputDir
  #define OutputDir "..\\..\\..\\..\\release"
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

procedure DeleteScheduledTask(const TaskName: string);
var
  Service, RootFolder: Variant;
begin
  try
    Service := CreateOleObject('Schedule.Service');
    Service.Connect();
    RootFolder := Service.GetFolder('\');
    try
      RootFolder.DeleteTask(TaskName, 0);
      Log('Deleted scheduled task: ' + TaskName);
    except
      Log('Scheduled task did not exist or could not be deleted: ' + TaskName);
    end;
  except
    Log('Task Scheduler COM unavailable while deleting ' + TaskName);
  end;
end;

procedure CreateLogonTask(const TaskName, Description, ExePath: string);
var
  Service, RootFolder, Definition, Trigger, Action, Principal: Variant;
  UserName, DomainName, AccountName: string;
begin
  UserName := GetEnv('USERNAME');
  DomainName := GetEnv('USERDOMAIN');
  if UserName = '' then
    UserName := ExpandConstant('{username}');
  if DomainName <> '' then
    AccountName := DomainName + '\\' + UserName
  else
    AccountName := UserName;
  Log('Creating logon task for account: ' + AccountName);
  Service := CreateOleObject('Schedule.Service');
  Service.Connect();
  RootFolder := Service.GetFolder('\');

  try
    RootFolder.DeleteTask(TaskName, 0);
  except
  end;

  Definition := Service.NewTask(0);
  Definition.RegistrationInfo.Description := Description;
  Definition.Settings.Enabled := True;
  Definition.Settings.StartWhenAvailable := True;
  Definition.Settings.DisallowStartIfOnBatteries := False;
  Definition.Settings.StopIfGoingOnBatteries := False;
  Definition.Settings.ExecutionTimeLimit := 'PT0S';
  Definition.Settings.MultipleInstances := 2;

  Principal := Definition.Principal;
  Principal.UserId := AccountName;
  Principal.LogonType := 3;
  Principal.RunLevel := 1;

  Trigger := Definition.Triggers.Create(9);
  Trigger.Enabled := True;
  Trigger.UserId := AccountName;

  Action := Definition.Actions.Create(0);
  Action.Path := ExePath;
  Action.WorkingDirectory := ExtractFileDir(ExePath);

  RootFolder.RegisterTaskDefinition(TaskName, Definition, 6, Null, Null, 3, Null);
  Log('Created interactive highest-privilege logon task: ' + TaskName + ' for ' + AccountName);
end;

procedure ConfigureSystem;
var
  AppExe, WatchdogExe, DataDir: string;
begin
  AppExe := ExpandConstant('{app}\BlazePisonet.SoftTimer.exe');
  WatchdogExe := ExpandConstant('{app}\BlazePisonet.SoftTimer.Watchdog.exe');
  DataDir := ExpandConstant('{commonappdata}\BlazeSystems\BlazePisonetSoftTimer');

  DeleteIfExists(DataDir + '\maintenance.until');

  try
    CreateLogonTask(
      'BlazePisonet SoftTimer',
      'Starts BlazePisonet SoftTimer for the current Pisonet Windows account.',
      AppExe);
    CreateLogonTask(
      'BlazePisonet SoftTimer Watchdog',
      'Keeps BlazePisonet SoftTimer available after an unexpected process exit.',
      WatchdogExe);
  except
    Log('Could not create one or more SoftTimer startup tasks: ' + GetExceptionMessage);
  end;

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

  DeleteScheduledTask('BlazePisonet SoftTimer');
  DeleteScheduledTask('BlazePisonet SoftTimer Watchdog');
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
