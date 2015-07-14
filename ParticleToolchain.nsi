; example2.nsi
;
; This script is based on example1.nsi, but it remember the directory,
; has uninstall support and (optionally) installs start menu shortcuts.
;
; It will install example2.nsi into a directory that the user selects,

;--------------------------------

; The name of the installer
Name "Particle Toolchain"


!define GCC_ARM_ADDRESS "https://launchpad.net/gcc-arm-embedded/4.9/4.9-2015-q2-update/+download/gcc-arm-none-eabi-4_9-2015q2-20150609-win32.zip"
!define MAKE_BINARY_ADDRESS "http://sourceforge.net/projects/gnuwin32/files/make/3.81/make-3.81-bin.zip/download"
!define MAKE_DEPEND_ADDRESS "http://sourceforge.net/projects/gnuwin32/files/make/3.81/make-3.81-dep.zip/download"
!define MINGW_ADDRESS "http://sourceforge.net/projects/mingw/files/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip/download"

ShowInstDetails show

; The file to write
OutFile "ParticleToolchain.exe"

SetCompressor /solid lzma
XPStyle on
InstallColors /windows

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
  ;File "pathed.exe"
  ;File "addPath.bat"
  ;File "removePath.bat"
  RealProgress::SetProgress /NOUNLOAD 4

  Call InstallGccArm
  RealProgress::SetProgress /NOUNLOAD 36
  Call InstallMake
  RealProgress::SetProgress /NOUNLOAD 68
  Call InstallMinGW
  RealProgress::SetProgress /NOUNLOAD 99

  DetailPrint "Adding Paths"
  Push "$INSTDIR\toolchain\Make\bin"
  Call AddToPath
  Push "$INSTDIR\toolchain\GCC-ARM\bin"
  Call AddToPath
  Push "$INSTDIR\toolchain\MinGW" 
  Call AddToPath
  Push "$INSTDIR\toolchain\MinGW\msys\1.0\bin"
  Call AddToPath
  ;nsExec::ExecToLog "addPath.bat"



  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\ParticleToolchain "Install_Dir" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParticleToolchain" "DisplayName" "Particle Toolchain"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParticleToolchain" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParticleToolchain" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParticleToolchain" "NoRepair" 1
  WriteUninstaller "uninstall.exe"
  
  
  RealProgress::SetProgress /NOUNLOAD 100

SectionEnd


;--------------------------------

; Uninstaller

Section "Uninstall"

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParticleToolchain"
  DeleteRegKey HKLM SOFTWARE\ParticleToolchain
  ;nsExec::ExecToLog "removePath.bat"
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
  Push "$INSTDIR\toolchain\Make\bin"
  Call un.RemoveFromPath
  Push "$INSTDIR\toolchain\GCC-ARM\bin"
  Call un.RemoveFromPath
  Push "$INSTDIR\toolchain\MinGW" 
  Call un.RemoveFromPath
  Push "$INSTDIR\toolchain\MinGW\msys\1.0\bin"
  Call un.RemoveFromPath

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


;--------------------------------------------------------------------
; Path functions
;
; Based on example from:
; http://nsis.sourceforge.net/Path_Manipulation
;


!include "WinMessages.nsh"

; Registry Entry for environment (NT4,2000,XP)
; All users:
;!define Environ 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
; Current user only:
!define Environ 'HKCU "Environment"'


; AddToPath - Appends dir to PATH
;   (does not work on Win9x/ME)
;
; Usage:
;   Push "dir"
;   Call AddToPath

Function AddToPath
  Exch $0
  Push $1
  Push $2
  Push $3
  Push $4

  ; NSIS ReadRegStr returns empty string on string overflow
  ; Native calls are used here to check actual length of PATH

  ; $4 = RegOpenKey(HKEY_CURRENT_USER, "Environment", &$3)
  System::Call "advapi32::RegOpenKey(i 0x80000001, t'Environment', *i.r3) i.r4"
  IntCmp $4 0 0 done done
  ; $4 = RegQueryValueEx($3, "PATH", (DWORD*)0, (DWORD*)0, &$1, ($2=NSIS_MAX_STRLEN, &$2))
  ; RegCloseKey($3)
  System::Call "advapi32::RegQueryValueEx(i $3, t'PATH', i 0, i 0, t.r1, *i ${NSIS_MAX_STRLEN} r2) i.r4"
  System::Call "advapi32::RegCloseKey(i $3)"

  IntCmp $4 234 0 +4 +4 ; $4 == ERROR_MORE_DATA
    DetailPrint "AddToPath: original length $2 > ${NSIS_MAX_STRLEN}"
    MessageBox MB_OK "PATH not updated, original length $2 > ${NSIS_MAX_STRLEN}"
    Goto done

  IntCmp $4 0 +5 ; $4 != NO_ERROR
    IntCmp $4 2 +3 ; $4 != ERROR_FILE_NOT_FOUND
      DetailPrint "AddToPath: unexpected error code $4"
      Goto done
    StrCpy $1 ""

  ; Check if already in PATH
  Push "$1;"
  Push "$0;"
  Call StrStr
  Pop $2
  StrCmp $2 "" 0 done
  Push "$1;"
  Push "$0\;"
  Call StrStr
  Pop $2
  StrCmp $2 "" 0 done

  ; Prevent NSIS string overflow
  StrLen $2 $0
  StrLen $3 $1
  IntOp $2 $2 + $3
  IntOp $2 $2 + 2 ; $2 = strlen(dir) + strlen(PATH) + sizeof(";")
  IntCmp $2 ${NSIS_MAX_STRLEN} +4 +4 0
    DetailPrint "AddToPath: new length $2 > ${NSIS_MAX_STRLEN}"
    MessageBox MB_OK "PATH not updated, new length $2 > ${NSIS_MAX_STRLEN}."
    Goto done

  ; Append dir to PATH
  DetailPrint "Add to PATH: $0"
  StrCpy $2 $1 1 -1
  StrCmp $2 ";" 0 +2
    StrCpy $1 $1 -1 ; remove trailing ';'
  StrCmp $1 "" +2   ; no leading ';'
    StrCpy $0 "$1;$0"
  WriteRegExpandStr ${Environ} "PATH" $0
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

done:
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Pop $0
FunctionEnd


; RemoveFromPath - Removes dir from PATH
;
; Usage:
;   Push "dir"
;   Call RemoveFromPath

Function un.RemoveFromPath
  Exch $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $5
  Push $6

  ReadRegStr $1 ${Environ} "PATH"
  StrCpy $5 $1 1 -1
  StrCmp $5 ";" +2
    StrCpy $1 "$1;" ; ensure trailing ';'
  Push $1
  Push "$0;"
  Call un.StrStr
  Pop $2 ; pos of our dir
  StrCmp $2 "" done

  DetailPrint "Remove from PATH: $0"
  StrLen $3 "$0;"
  StrLen $4 $2
  StrCpy $5 $1 -$4 ; $5 is now the part before the path to remove
  StrCpy $6 $2 "" $3 ; $6 is now the part after the path to remove
  StrCpy $3 "$5$6"
  StrCpy $5 $3 1 -1
  StrCmp $5 ";" 0 +2
    StrCpy $3 $3 -1 ; remove trailing ';'
  WriteRegExpandStr ${Environ} "PATH" $3
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

done:
  Pop $6
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Pop $0
FunctionEnd
 

; StrStr - find substring in a string
;
; Usage:
;   Push "this is some string"
;   Push "some"
;   Call StrStr
;   Pop $0 ; "some string"

!macro StrStr un
Function ${un}StrStr
  Exch $R1 ; $R1=substring, stack=[old$R1,string,...]
  Exch     ;                stack=[string,old$R1,...]
  Exch $R2 ; $R2=string,    stack=[old$R2,old$R1,...]
  Push $R3
  Push $R4
  Push $R5
  StrLen $R3 $R1
  StrCpy $R4 0
  ; $R1=substring, $R2=string, $R3=strlen(substring)
  ; $R4=count, $R5=tmp
  loop:
    StrCpy $R5 $R2 $R3 $R4
    StrCmp $R5 $R1 done
    StrCmp $R5 "" done
    IntOp $R4 $R4 + 1
    Goto loop
done:
  StrCpy $R1 $R2 "" $R4
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Exch $R1 ; $R1=old$R1, stack=[result,...]
FunctionEnd
!macroend
!insertmacro StrStr ""
!insertmacro StrStr "un."
