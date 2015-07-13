; example2.nsi
;
; This script is based on example1.nsi, but it remember the directory,
; has uninstall support and (optionally) installs start menu shortcuts.
;
; It will install example2.nsi into a directory that the user selects,

;--------------------------------

; The name of the installer
Name "Particle Toolchain"


!define GCC_ARM_ADDRESS "https://launchpad.net/gcc-arm-embedded/4.9/4.9-2015-q1-update/+download/gcc-arm-none-eabi-4_9-2015q1-20150306-win32.zip"
!define MAKE_BINARY_ADDRESS "http://sourceforge.net/projects/gnuwin32/files/make/3.81/make-3.81-bin.zip/download"
!define MAKE_DEPEND_ADDRESS "http://sourceforge.net/projects/gnuwin32/files/make/3.81/make-3.81-dep.zip/download"
!define MINGW_ADDRESS "http://sourceforge.net/projects/mingw/files/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip/download"

ShowInstDetails show

; The file to write
OutFile "ParticleToolchain.exe"

; The default installation directory
Function .onInit
   StrCpy "$INSTDIR" "$WINDIR" 2
   StrCpy "$INSTDIR" "$INSTDIR\Particle"
   Var /GLOBAL TempFile
FunctionEnd

; Registry key to check for directory (so if you install again, it will
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\ParticleToolchain" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

;--------------------------------

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "ParticleToolchain (required)"
  AddSize 758776
  SectionIn RO

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR


  ; Put file there
  File "pathed.exe"
  File "addPath.bat"
  File "removePath.bat"
  RealProgress::SetProgress /NOUNLOAD 4

  Call InstallGccArm
  RealProgress::SetProgress /NOUNLOAD 36
  Call InstallMake
  RealProgress::SetProgress /NOUNLOAD 68
  Call InstallMinGW
  RealProgress::SetProgress /NOUNLOAD 99

  DetailPrint "Adding Paths"
  nsExec::ExecToLog "addPath.bat"



  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\ParticleToolchain "Install_Dir" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParticleToolchain" "DisplayName" "Particle Toolchain"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParticleToolchain" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParticleToolchain" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParticleToolchain" "NoRepair" 1
  WriteUninstaller "uninstall.exe"

SectionEnd


;--------------------------------

; Uninstaller

Section "Uninstall"

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParticleToolchain"
  DeleteRegKey HKLM SOFTWARE\ParticleToolchain
  nsExec::ExecToLog "removePath.bat"
  RMDir /r /REBOOTOK "$INSTDir\Toolchain"
  Delete "$INSTDir\removePath.bat"
  Delete "$INSTDir\addPath.bat"
  Delete "$INSTDir\pathed.exe"




  ; Remove files and uninstaller
;  Delete $INSTDIR\ParticleToolchain.nsi
  Delete $INSTDIR\uninstall.exe

  ; Remove shortcuts, if any
  ;Delete "$SMPROGRAMS\Example2\*.*"

  ; Remove directories used
 ; RMDir "$SMPROGRAMS\Example2"
  RMDir "$INSTDIR"

SectionEnd


Function InstallGccArm
  StrCpy "$TempFile" "$TEMP\gcc-arm.zip"
  inetc::get "${GCC_ARM_ADDRESS}" "$TempFile"
  Pop $0
  StrCmp $0 "OK" dlok
    SetDetailsView show
    MessageBox MB_OK|MB_ICONEXCLAMATION "http download Error, click OK to abort installation" /SD IDOK
    Abort
  dlok:
  RealProgress::SetProgress /NOUNLOAD 20
    CreateDirectory "$INSTDIR\Toolchain\GCC-ARM"
    nsisunz::UnzipToLog "$TempFile" "$INSTDIR\Toolchain\GCC-ARM\"
    Delete "$TempFile"

FunctionEnd

Function InstallMake
  StrCpy "$TempFile" "$TEMP\make_bin.zip"
  inetc::get /USERAGENT "Wget/1.9.1" "${MAKE_BINARY_ADDRESS}" "$TempFile"
  Pop $0
  StrCmp $0 "OK" dlok
    SetDetailsView show
    MessageBox MB_OK|MB_ICONEXCLAMATION "http download Error, click OK to abort installation" /SD IDOK
    Abort
  dlok:
  RealProgress::SetProgress /NOUNLOAD 52
  CreateDirectory "$INSTDIR\Toolchain\Make"
  nsisunz::UnzipToLog "$TempFile" "$INSTDIR\Toolchain\Make\"
  Delete "$TempFile"

  StrCpy "$TempFile" "$TEMP\make_libs.zip"
  inetc::get /USERAGENT "Wget/1.9.1" "${MAKE_DEPEND_ADDRESS}" "$TempFile"
  Pop $0
  StrCmp $0 "OK" dlok2
    SetDetailsView show
    MessageBox MB_OK|MB_ICONEXCLAMATION "http download Error, click OK to abort installation" /SD IDOK
    Abort

  dlok2:
  nsisunz::UnzipToLog "$TempFile" "$INSTDIR\Toolchain\Make\"
  Delete "$TempFile"
FunctionEnd

Function InstallMinGW
  StrCpy "$TempFile" "$TEMP\mingw.zip"
  inetc::get /USERAGENT "Wget/1.9.1" "${MINGW_ADDRESS}" "$TempFile"
  Pop $0
  StrCmp $0 "OK" dlok
    SetDetailsView show
    MessageBox MB_OK|MB_ICONEXCLAMATION "http download Error, click OK to abort installation" /SD IDOK
    Abort
  dlok:
  RealProgress::SetProgress /NOUNLOAD 70
  CreateDirectory "$INSTDIR\Toolchain\MinGW"
  nsisunz::UnzipToLog "$TempFile" "$INSTDIR\Toolchain\MinGW\"

  Delete "$TempFile"
  RealProgress::SetProgress /NOUNLOAD 72

  DetailPrint "Downloading and Installing MinGW Packages"
  nsExec::ExecToLog '"$INSTDIR\Toolchain\MinGW\bin\mingw-get.exe" install mingw32-base mingw32-gcc-g++ msys-make mingw-developer-toolkit'

FunctionEnd
