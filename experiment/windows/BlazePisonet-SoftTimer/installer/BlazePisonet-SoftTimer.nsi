Unicode True
RequestExecutionLevel admin
ManifestDPIAware true
Name "BlazePisonet SoftTimer"
OutFile "..\..\..\..\release\BlazePisonet-SoftTimer-Setup-v0.2.0.exe"
InstallDir "$PROGRAMFILES64\BlazeSystems\BlazePisonet SoftTimer"
InstallDirRegKey HKLM "Software\BlazeSystems\BlazePisonet SoftTimer" "InstallDir"
SetCompressor /SOLID lzma
SetCompressorDictSize 64
BrandingText "BlazeSystems · BlazePisonet SoftTimer"
VIProductVersion "0.2.0.0"
VIAddVersionKey /LANG=1033 "ProductName" "BlazePisonet SoftTimer"
VIAddVersionKey /LANG=1033 "ProductVersion" "0.2.0"
VIAddVersionKey /LANG=1033 "CompanyName" "BlazeSystems"
VIAddVersionKey /LANG=1033 "FileDescription" "BlazePisonet SoftTimer Setup"
VIAddVersionKey /LANG=1033 "FileVersion" "0.2.0.0"

!include "MUI2.nsh"
!include "LogicLib.nsh"

!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!define MUI_FINISHPAGE_RUN "$INSTDIR\BlazePisonet.SoftTimer.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch BlazePisonet SoftTimer"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

Var TaskResult
Var TaskOutput

Function CreateStartupTasks
  nsExec::ExecToStack '$\"$SYSDIR\schtasks.exe$\" /Delete /TN $\"BlazePisonet SoftTimer$\" /F'
  Pop $TaskResult
  Pop $TaskOutput
  nsExec::ExecToStack '$\"$SYSDIR\schtasks.exe$\" /Delete /TN $\"BlazePisonet SoftTimer Watchdog$\" /F'
  Pop $TaskResult
  Pop $TaskOutput

  DetailPrint "Creating interactive SoftTimer logon task..."
  nsExec::ExecToStack '$\"$SYSDIR\schtasks.exe$\" /Create /TN $\"BlazePisonet SoftTimer$\" /TR $\"$INSTDIR\BlazePisonet.SoftTimer.exe$\" /SC ONLOGON /RL HIGHEST /IT /F'
  Pop $TaskResult
  Pop $TaskOutput
  DetailPrint "$TaskOutput"
  ${If} $TaskResult != "0"
    DetailPrint "SoftTimer startup task creation failed with exit code $TaskResult"
    SetErrorLevel 1603
    Abort "Windows could not create the BlazePisonet SoftTimer startup task."
  ${EndIf}

  DetailPrint "Creating interactive SoftTimer watchdog logon task..."
  nsExec::ExecToStack '$\"$SYSDIR\schtasks.exe$\" /Create /TN $\"BlazePisonet SoftTimer Watchdog$\" /TR $\"$INSTDIR\BlazePisonet.SoftTimer.Watchdog.exe$\" /SC ONLOGON /RL HIGHEST /IT /F'
  Pop $TaskResult
  Pop $TaskOutput
  DetailPrint "$TaskOutput"
  ${If} $TaskResult != "0"
    DetailPrint "Watchdog startup task creation failed with exit code $TaskResult"
    nsExec::ExecToStack '$\"$SYSDIR\schtasks.exe$\" /Delete /TN $\"BlazePisonet SoftTimer$\" /F'
    Pop $TaskResult
    Pop $TaskOutput
    SetErrorLevel 1603
    Abort "Windows could not create the BlazePisonet SoftTimer watchdog startup task."
  ${EndIf}
FunctionEnd

Function ConfigureFirewall
  nsExec::ExecToStack '$\"$SYSDIR\netsh.exe$\" advfirewall firewall delete rule name=$\"BlazePisonet SoftTimer Centralized$\"'
  Pop $TaskResult
  Pop $TaskOutput
  nsExec::ExecToStack '$\"$SYSDIR\netsh.exe$\" advfirewall firewall add rule name=$\"BlazePisonet SoftTimer Centralized$\" dir=in action=allow protocol=TCP localport=8765 remoteip=LocalSubnet profile=private'
  Pop $TaskResult
  Pop $TaskOutput
  DetailPrint "$TaskOutput"
FunctionEnd

Section "BlazePisonet SoftTimer" SEC_MAIN
  SectionIn RO
  SetShellVarContext all
  SetOutPath "$INSTDIR"

  File "..\..\..\..\out\bundle\BlazePisonet.SoftTimer.exe"
  File "..\..\..\..\out\bundle\BlazePisonet.SoftTimer.Watchdog.exe"

  CreateDirectory "$COMMONAPPDATA\BlazeSystems\BlazePisonetSoftTimer"
  nsExec::ExecToStack '$\"$SYSDIR\icacls.exe$\" $\"$COMMONAPPDATA\BlazeSystems\BlazePisonetSoftTimer$\" /inheritance:r /grant:r *S-1-5-18:(OI)(CI)F *S-1-5-32-544:(OI)(CI)F /T /C'
  Pop $TaskResult
  Pop $TaskOutput
  DetailPrint "$TaskOutput"

  Delete "$COMMONAPPDATA\BlazeSystems\BlazePisonetSoftTimer\maintenance.until"

  CreateDirectory "$SMPROGRAMS\BlazePisonet SoftTimer"
  CreateShortcut "$SMPROGRAMS\BlazePisonet SoftTimer\BlazePisonet SoftTimer.lnk" "$INSTDIR\BlazePisonet.SoftTimer.exe"
  CreateShortcut "$SMPROGRAMS\BlazePisonet SoftTimer\Uninstall BlazePisonet SoftTimer.lnk" "$INSTDIR\Uninstall.exe"

  WriteUninstaller "$INSTDIR\Uninstall.exe"

  WriteRegStr HKLM "Software\BlazeSystems\BlazePisonet SoftTimer" "InstallDir" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BlazePisonetSoftTimer" "DisplayName" "BlazePisonet SoftTimer"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BlazePisonetSoftTimer" "DisplayVersion" "0.2.0"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BlazePisonetSoftTimer" "Publisher" "BlazeSystems"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BlazePisonetSoftTimer" "DisplayIcon" "$INSTDIR\BlazePisonet.SoftTimer.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BlazePisonetSoftTimer" "UninstallString" '$\"$INSTDIR\Uninstall.exe$\"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BlazePisonetSoftTimer" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BlazePisonetSoftTimer" "NoRepair" 1

  Call CreateStartupTasks
  Call ConfigureFirewall
SectionEnd

Section "Desktop shortcut" SEC_DESKTOP
  SetShellVarContext all
  CreateShortcut "$DESKTOP\BlazePisonet SoftTimer.lnk" "$INSTDIR\BlazePisonet.SoftTimer.exe"
SectionEnd

Section "Uninstall"
  SetShellVarContext all

  CreateDirectory "$COMMONAPPDATA\BlazeSystems\BlazePisonetSoftTimer"
  FileOpen $0 "$COMMONAPPDATA\BlazeSystems\BlazePisonetSoftTimer\maintenance.until" w
  FileWrite $0 "4102444800"
  FileClose $0

  nsExec::ExecToStack '$\"$SYSDIR\schtasks.exe$\" /Delete /TN $\"BlazePisonet SoftTimer$\" /F'
  Pop $TaskResult
  Pop $TaskOutput
  nsExec::ExecToStack '$\"$SYSDIR\schtasks.exe$\" /Delete /TN $\"BlazePisonet SoftTimer Watchdog$\" /F'
  Pop $TaskResult
  Pop $TaskOutput

  nsExec::ExecToStack '$\"$SYSDIR\taskkill.exe$\" /IM BlazePisonet.SoftTimer.exe /F'
  Pop $TaskResult
  Pop $TaskOutput
  nsExec::ExecToStack '$\"$SYSDIR\taskkill.exe$\" /IM BlazePisonet.SoftTimer.Watchdog.exe /F'
  Pop $TaskResult
  Pop $TaskOutput

  nsExec::ExecToStack '$\"$SYSDIR\netsh.exe$\" advfirewall firewall delete rule name=$\"BlazePisonet SoftTimer Centralized$\"'
  Pop $TaskResult
  Pop $TaskOutput

  Delete "$DESKTOP\BlazePisonet SoftTimer.lnk"
  Delete "$SMPROGRAMS\BlazePisonet SoftTimer\BlazePisonet SoftTimer.lnk"
  Delete "$SMPROGRAMS\BlazePisonet SoftTimer\Uninstall BlazePisonet SoftTimer.lnk"
  RMDir "$SMPROGRAMS\BlazePisonet SoftTimer"

  Delete "$INSTDIR\BlazePisonet.SoftTimer.exe"
  Delete "$INSTDIR\BlazePisonet.SoftTimer.Watchdog.exe"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BlazePisonetSoftTimer"
  DeleteRegKey HKLM "Software\BlazeSystems\BlazePisonet SoftTimer"
SectionEnd
