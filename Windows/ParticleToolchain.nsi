; example2.nsi
;
; This script is based on example1.nsi, but it remember the directory,
; has uninstall support and (optionally) installs start menu shortcuts.
;
; It will install example2.nsi into a directory that the user selects,

;--------------------------------



SetCompressor /solid lzma

; The name of the installer
Name "Particle Toolchain"
!include 'LogicLib.nsh'
!include 'Sections.nsh'
!include 'TextFunc.nsh'
!include "DotNetChecker.nsh"
!define PRODUCT_NAME "Particle Toolchain"
!include 'x64.nsh'
!insertmacro VersionCompare
!insertmacro ConfigWrite
 

!macro _StrReplaceConstructor ORIGINAL_STRING TO_REPLACE REPLACE_BY
  Push "${ORIGINAL_STRING}"
  Push "${TO_REPLACE}"
  Push "${REPLACE_BY}"
  Call StrRep
  Pop $0
!macroend
 
!define StrReplace '!insertmacro "_StrReplaceConstructor"'


!define JSON_ADDRESS "https://gist.githubusercontent.com/mumblepins/bfcd148d7f4d470d6f20/raw"
ShowInstDetails show

; The file to write
OutFile "ParticleToolchain.exe"

XPStyle on
InstallColors /windows

; The default installation directory
Function .onInit
    StrCpy "$INSTDIR" "$WINDIR" 2
    StrCpy "$INSTDIR" "$INSTDIR\Particle"
    
    Var /GLOBAL TempFile
    Var /GLOBAL TempString
    
    Var /GLOBAL GCC_ARM_ADDRESS
    Var /GLOBAL MAKE_BINARY_ADDRESS
    Var /GLOBAL MAKE_DEPEND_ADDRESS
    Var /GLOBAL MINGW_ADDRESS
    Var /GLOBAL GIT_ADDRESS
    Var /GLOBAL NETBEANS_ADDRESS
    Var /GLOBAL JDK_ADDRESS
    Var /GLOBAL JDK64_ADDRESS
    Var /GLOBAL CYGWIN_ADDR
    Var /GLOBAL CYGWIN64_ADDR
    Var /GLOBAL NODE_ADDR
    Var /GLOBAL NODE64_ADDR
    Var /GLOBAL PYTHON_ADDR
    Var /GLOBAL PYTHON64_ADDR
    Var /GLOBAL MSBUILD_ADDR
    
    Var /GLOBAL GCC_ARM_VER
    Var /GLOBAL MAKE_BINARY_VER
    Var /GLOBAL MAKE_DEPEND_VER
    Var /GLOBAL MINGW_VER
    Var /GLOBAL GIT_VER
    Var /GLOBAL NETBEANS_VER
    Var /GLOBAL JDK_VER
    Var /GLOBAL JDK64_VER
    Var /GLOBAL CYGWIN_VER
    Var /GLOBAL CYGWIN64_VER
    Var /GLOBAL NODE_VER
    Var /GLOBAL NODE64_VER
    Var /GLOBAL PYTHON_VER
    Var /GLOBAL PYTHON64_VER
    Var /GLOBAL MSBUILD_VER
    
    StrCpy "$TempFile" "$TEMP\release_info.json"
    inetc::get /QUESTION "" /BANNER "Downloading Installation Info"  /CAPTION "Downloading..." /RESUME "" "${JSON_ADDRESS}" "$TempFile" /END
    nsJSON::Set /file "$TempFile"
    ClearErrors
    nsJSON::Get /noexpand `GCC` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$GCC_ARM_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `MAKE_BIN` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MAKE_BINARY_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `MAKE_DEP` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MAKE_DEPEND_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `MINGW` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MINGW_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `GIT` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$GIT_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `NETBEANS` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$NETBEANS_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `JDK` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$JDK_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `JDK64` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$JDK64_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `CYGWIN_X86` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$CYGWIN_ADDR" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `CYGWIN_X86_64` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$CYGWIN64_ADDR" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `NODEJS` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$NODE_ADDR" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `NODEJS_64` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$NODE64_ADDR" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `PYTHON` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$PYTHON_ADDR" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `PYTHON64` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$PYTHON64_ADDR" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `MS_BUILD` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MSBUILD_ADDR" "$R0"
    ${EndIf}
    
    
    
    
    ClearErrors
    nsJSON::Get /noexpand `GCC` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$GCC_ARM_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `MAKE_BIN` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MAKE_BINARY_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `MAKE_DEP` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MAKE_DEPEND_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `MINGW` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MINGW_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `GIT` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$GIT_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `NETBEANS` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$NETBEANS_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `JDK` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$JDK_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `JDK64` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$JDK64_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `CYGWIN_X86` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$CYGWIN_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `CYGWIN_X86_64` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$CYGWIN64_VER" "$R0"
    ${EndIf}
    
     ClearErrors
    nsJSON::Get /noexpand `NODEJS` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$NODE_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `NODEJS_64` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$NODE64_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `PYTHON` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$PYTHON_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `PYTHON64` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$PYTHON64_VER" "$R0"
    ${EndIf}
     
    ClearErrors
    nsJSON::Get /noexpand `MS_BUILD` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MSBUILD_VER" "$R0"
    ${EndIf}
    
    
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

InstType "Full"
InstType "Toolchain Only"



;--------------------------------

; The stuff to install


SectionGroup "Toolchain"
    Section "Make"
        SectionIn 1 2
        ;AddSize 758776
        DetailPrint "Installing Make"

        Call InstallMake

        DetailPrint "Adding Path"
        Push "$INSTDIR\toolchain\Make\bin"
        Call AddToPath
        
    SectionEnd
    
    Section "MinGW"
        SectionIn 1 2
        ;AddSize 758776
        DetailPrint "Installing MinGW"

        ; Set output path to the installation directory.
        SetOutPath $INSTDIR

        Call InstallMinGW

        DetailPrint "Adding Path"
        Push "$INSTDIR\toolchain\MinGW"
        Call AddToPath
        Push "$INSTDIR\toolchain\MinGW\msys\1.0\bin"
        Call AddToPath
        
    SectionEnd
    
    Section "GCC ARM"
        SectionIn 1 2
        ;AddSize 758776
        DetailPrint "Installing GCC ARM"

        ; Set output path to the installation directory.
        SetOutPath $INSTDIR

        Call InstallGccArm

        DetailPrint "Adding Path"
        Push "$INSTDIR\toolchain\GCC-ARM\bin"
        Call AddToPath
        
    SectionEnd
SectionGroupEnd

Section Git
    SectionIn 1
    DetailPrint "Installing Git"
    Call InstallGit
SectionEnd

SectionGroup "Netbeans (Install JDK if not installed)" SEC_GRP
    Section "Netbeans" SEC_REQ
        SectionIn 1 RO
        DetailPrint "Installing Netbeans"
        Call InstallNetbeans
        
    SectionEnd
    
    Section "Config" SEC_OPT
        SectionIn 1
        DetailPrint "Writing Netbeans Config"
        Call WriteToolchainProperties
    SectionEnd
    
    Section "" PRIVSEC_TOGGLESTATE ;hidden section to keep track of state
    SectionEnd
SectionGroupEnd

Section "Cygwin (needed for automatic build in Netbeans)"
    SectionIn 1
    DetailPrint "Installing Cygwin"
    Call InstallCygwin
SectionEnd

SectionGroup "Particle Firmware" SEC_GRP1
    Section "Firmware" SEC_REQ1
        SectionIn 1 RO
        SetOutPath "$INSTDIR"
        DetailPrint "Git Clone Firmware"
        nsExec::ExecToLog "git clone https://github.com/spark/firmware"
        SetOutPath "$INSTDIR\firmware"
        nsExec::ExecToLog "git checkout latest"
    SectionEnd
        
    Section "Netbeans Project" SEC_OPT1
        SectionIn 1
        SetOutPath "$INSTDIR\NBProjects\ParticleFirmware\nbproject"
        File configurations.xml
        File project.xml
        SetOutPath "$INSTDIR\NBProjects\ParticleFirmware\nbproject\private"
        File CodeAssistancePathMapper.properties
        File /oname=configurations.xml private_configurations.xml
        File private.xml
        File Core.properties
        File Launcher.properties
    SectionEnd
    
    Section "" PRIVSEC_TOGGLESTATE1 ;hidden section to keep track of state
    SectionEnd
SectionGroupEnd

Section "Particle CLI"
	SectionIn 1
	Call InstallParticleCLI
SectionEnd

Section "DFU Util"
	SectionIn 1
	SetOutPath "$INSTDIR\Tools\DFU-util"
	File dfu*.exe
	File libusb*.dll
	DetailPrint "Adding Path"
	Push "$INSTDIR\Tools\DFU-util"
	Call AddToPath
SectionEnd

Section
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


Function .onSelChange
    !define /math SECFLAGS_SELRO ${SF_SELECTED} | ${SF_RO}
    ${IfNot} ${SectionIsSelected} ${PRIVSEC_TOGGLESTATE}
    ${AndIf} ${SectionIsReadOnly} ${SEC_REQ}
        !insertmacro ClearSectionFlag ${SEC_REQ} ${SECFLAGS_SELRO}
    ${EndIf}
    ${If} ${SectionIsSelected} ${SEC_OPT}
        !insertmacro SetSectionFlag ${SEC_REQ} ${SECFLAGS_SELRO} 
    ${Else}
        !insertmacro ClearSectionFlag ${SEC_REQ} ${SF_RO}
    ${EndIf}
    ${If} ${SectionIsSelected} ${SEC_REQ}
        !insertmacro SelectSection ${PRIVSEC_TOGGLESTATE}
    ${Else}
        !insertmacro UnselectSection ${PRIVSEC_TOGGLESTATE}
    ${EndIf}
    
    ${IfNot} ${SectionIsSelected} ${PRIVSEC_TOGGLESTATE1}
    ${AndIf} ${SectionIsReadOnly} ${SEC_REQ1}
        !insertmacro ClearSectionFlag ${SEC_REQ1} ${SECFLAGS_SELRO}
    ${EndIf}
    ${If} ${SectionIsSelected} ${SEC_OPT1}
        !insertmacro SetSectionFlag ${SEC_REQ1} ${SECFLAGS_SELRO} 
    ${Else}
        !insertmacro ClearSectionFlag ${SEC_REQ1} ${SF_RO}
    ${EndIf}
    ${If} ${SectionIsSelected} ${SEC_REQ1}
        !insertmacro SelectSection ${PRIVSEC_TOGGLESTATE1}
    ${Else}
        !insertmacro UnselectSection ${PRIVSEC_TOGGLESTATE1}
    ${EndIf}
    !undef SECFLAGS_SELRO
    
    
FunctionEnd

Function InstallGccArm
    StrCpy "$TempFile" "$TEMP\gcc-arm.zip"
    Download:
    
    inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$GCC_ARM_ADDRESS" "$TempFile" /END
    Pop $0
    StrCmp $0 "OK" dlok
    SetDetailsView show
    DetailPrint "Error: $0"
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download error, Retry?" /SD IDCANCEL IDRETRY Download
    Abort
    dlok:
    CreateDirectory "$INSTDIR\Toolchain\GCC-ARM"
    nsisunz::UnzipToLog "$TempFile" "$INSTDIR\Toolchain\GCC-ARM\"
    Delete "$TempFile"

FunctionEnd

Function InstallMake
    StrCpy "$TempFile" "$TEMP\make_bin.zip"
    Download:
    
    inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$MAKE_BINARY_ADDRESS" "$TempFile" /END
    Pop $0
    StrCmp $0 "OK" dlok
    SetDetailsView show
    DetailPrint "Error: $0"
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download error, Retry?" /SD IDCANCEL IDRETRY Download
    Abort
    dlok:
    CreateDirectory "$INSTDIR\Toolchain\Make"
    nsisunz::UnzipToLog "$TempFile" "$INSTDIR\Toolchain\Make\"
    Delete "$TempFile"

    StrCpy "$TempFile" "$TEMP\make_libs.zip"
    Download2:
    
    inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$MAKE_DEPEND_ADDRESS" "$TempFile" /END
    Pop $0
    StrCmp $0 "OK" dlok2
    SetDetailsView show
    DetailPrint "Error: $0"
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download error, Retry?" /SD IDCANCEL IDRETRY Download2
    Abort

    dlok2:
    nsisunz::UnzipToLog "$TempFile" "$INSTDIR\Toolchain\Make\"
    Delete "$TempFile"
FunctionEnd

Function InstallMinGW
    StrCpy "$TempFile" "$TEMP\mingw.zip"
    Download:
    
    inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$MINGW_ADDRESS" "$TempFile" /END
    Pop $0
    StrCmp $0 "OK" dlok
    SetDetailsView show
    DetailPrint "Error: $0"
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download error, Retry?" /SD IDCANCEL IDRETRY Download
    Abort
    dlok:
    CreateDirectory "$INSTDIR\Toolchain\MinGW"
    nsisunz::UnzipToLog "$TempFile" "$INSTDIR\Toolchain\MinGW\"

    Delete "$TempFile"

    DetailPrint "Downloading and Installing MinGW Packages"
    nsExec::ExecToLog '"$INSTDIR\Toolchain\MinGW\bin\mingw-get.exe" install mingw32-base mingw32-gcc-g++ msys-make mingw-developer-toolkit'
FunctionEnd

Function InstallGit
    StrCpy "$TempFile" "$TEMP\git.exe"
    Download:
    
    inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$GIT_ADDRESS" "$TempFile" /END
    Pop $0
    StrCmp $0 "OK" dlok
    SetDetailsView show
    DetailPrint "Error: $0"
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download error, Retry?" /SD IDCANCEL IDRETRY Download
    Abort
    dlok:
    CreateDirectory "$INSTDIR\Tools\Git"
    SetOutPath $TEMP
    File "git_setup.inf"
    ExecWait '"$TempFile" /SILENT /SP- /DIR=$INSTDIR\Tools\Git /LOADINF="$TEMP\git_setup.inf"'
    Delete "$TEMP\git_setup.inf"
    Delete "$TempFile"

FunctionEnd

Function InstallNetbeans

    ClearErrors
    ReadRegStr $1 HKLM "SOFTWARE\JavaSoft\Java Development Kit" "CurrentVersion"
    ReadRegStr $2 HKLM "SOFTWARE\JavaSoft\Java Development Kit\$1" "JavaHome"
    
    IfErrors 0 JavaInstalled
        Call InstallJDK
        Goto JavaInstalledAndUpdated
    JavaInstalled:
    ${VersionCompare} $1 "1.7" $R0
    ${If} $R0 == 2
        DetailPrint "Need to update JDK"
        Call InstallJDK
    ${EndIf}
    JavaInstalledAndUpdated:
    DetailPrint "Installing Netbeans"
    StrCpy "$TempFile" "$TEMP\netbeans.exe"
    Download:
    
    inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$NETBEANS_ADDRESS" "$TempFile" /END
    Pop $0
    StrCmp $0 "OK" dlok
    SetDetailsView show
    DetailPrint "Error: $0"
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download error, Retry?" /SD IDCANCEL IDRETRY Download
    Abort
    dlok:
    CreateDirectory "$INSTDIR\Tools\Netbeans"
    ExecWait '"$TempFile" --silent "-J-Dnb-base.installation.location=$INSTDIR\Tools\Netbeans"'
    Delete "$TempFile"
    
    
FunctionEnd

Function InstallJDK
    DetailPrint "Installing JDK"
    StrCpy "$TempFile" "$TEMP\JDK_installer.exe"
    
    Download:
    ${If} ${RunningX64}
        ; 64 bit code
        inetc::get /QUESTION "" /RESUME ""\
            /USERAGENT "Wget/1.9.1" /NOCOOKIES /HEADER "Cookie: oraclelicense=accept-securebackup-cookie" "$JDK64_ADDRESS" "$TempFile" /END
        ;ExecWait "$INSTDIR\Ninite JDK x64 8 Installer.exe"
        ;Delete "$INSTDIR\Ninite JDK x64 8 Installer.exe"
        
    ${Else}
        ; 32 bit code
        inetc::get /QUESTION "" /RESUME ""\
            /USERAGENT "Wget/1.9.1" /NOCOOKIES /HEADER "Cookie: oraclelicense=accept-securebackup-cookie" "$JDK_ADDRESS" "$TempFile" /END
        ;ExecWait "$INSTDIR\Ninite JDK 8 Installer.exe"
        ;Delete "$INSTDIR\Ninite JDK 8 Installer.exe"
    ${EndIf}
    Pop $0
    StrCmp $0 "OK" dlok
    SetDetailsView show
    DetailPrint "Error: $0"
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download error, Retry?" /SD IDCANCEL IDRETRY Download
    Abort
    dlok:
    
    ExecWait "$TempFile /s"
    Delete "$TempFile"
FunctionEnd

Function InstallCygwin
    DetailPrint "Installing Cygwin"
    CreateDirectory "$INSTDIR\Cygwin"
    StrCpy "$TempFile" "$INSTDIR\Cygwin\Cygwin_setup.exe"
    
    Download:
    ;${If} ${RunningX64}
        ;; 64 bit code
        ;inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$CYGWIN64_ADDR" "$TempFile" /END
    ;${Else}
        ; 32 bit code
        inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$CYGWIN_ADDR" "$TempFile" /END
    ;${EndIf}
    Pop $0
    StrCmp $0 "OK" dlok
    SetDetailsView show
    DetailPrint "Error: $0"
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download error, Retry?" /SD IDCANCEL IDRETRY Download
    Abort
    dlok:
    ExecWait '"$TempFile" -q -R "$INSTDIR\Tools\Cygwin" -l "$INSTDIR\Tools\Cygwin\Packages" -s "http://cygwin.mirror.constant.com"'
FunctionEnd

Function InstallParticleCLI

    SetOutPath "$InstDir"
	DetailPrint "Downloading NodeJS"
    StrCpy "$TempFile" "$TEMP\node_setup.msi"
    Download:
    ${If} ${RunningX64}
        ; 64 bit code
        inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$NODE64_ADDR" "$TempFile" /END
    ${Else}
        ; 32 bit code
        inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$NODE_ADDR" "$TempFile" /END
    ${EndIf}
    Pop $0
    StrCmp $0 "OK" dlok
    SetDetailsView show
    DetailPrint "Error: $0"
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download error, Retry?" /SD IDCANCEL IDRETRY Download
    Abort
    dlok:
    DetailPrint "Installing NodeJS"
    ;SetDetailsPrint none
    ExecWait 'msiexec /i "$TempFile" INSTALLDIR="$INSTDIR\Tools\NodeJS" /passive'
    SetDetailsPrint both
    Delete "$TempFile"
    
    !insertmacro CheckNetFramework 451
    
    DetailPrint "Downloading MS Build Tools"
    SetOutPath "$InstDir"
    StrCpy "$TempFile" "$TEMP\buildtools.exe"
    Download1:
    inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$MSBUILD_ADDR" "$TempFile" /END
    Pop $0
    StrCmp $0 "OK" dlok1
    SetDetailsView show
    DetailPrint "Error: $0"
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download error, Retry?" /SD IDCANCEL IDRETRY Download1
    Abort
    dlok1:
    DetailPrint "Installing MS Build Tools"
   ; SetDetailsPrint none
    ExecWait '"$TempFile" /Passive'
    SetDetailsPrint both
    Delete "$TempFile"
    
	DetailPrint "Downloading Python"
    StrCpy "$TempFile" "$TEMP\python_setup.msi"
    Download2:
    ${If} ${RunningX64}
        ; 64 bit code
        inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$PYTHON64_ADDR" "$TempFile" /END
    ${Else}
        ; 32 bit code
        inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$PYTHON_ADDR" "$TempFile" /END
    ${EndIf}
    Pop $0
    StrCmp $0 "OK" dlok2
    SetDetailsView show
    DetailPrint "Error: $0"
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download error, Retry?" /SD IDCANCEL IDRETRY Download2
    Abort
    dlok2:
    DetailPrint "Installing Python"
    ;SetDetailsPrint none
    ExecWait 'msiexec /i "$TempFile" TARGETDIR="$INSTDIR\Tools\Python27" ALLUSERS=1 /passive'
    SetDetailsPrint both
    Delete "$TempFile"
    
    DetailPrint "Installing Particle CLI"
   ; SetDetailsPrint none
    nsExec::ExecToLog '"$INSTDIR\Tools\NodeJS\npm.cmd" install -g particle-cli'
    SetDetailsPrint both
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



Function StrRep
  Exch $R4 ; $R4 = Replacement String
  Exch
  Exch $R3 ; $R3 = String to replace (needle)
  Exch 2
  Exch $R1 ; $R1 = String to do replacement in (haystack)
  Push $R2 ; Replaced haystack
  Push $R5 ; Len (needle)
  Push $R6 ; len (haystack)
  Push $R7 ; Scratch reg
  StrCpy $R2 ""
  StrLen $R5 $R3
  StrLen $R6 $R1
loop:
  StrCpy $R7 $R1 $R5
  StrCmp $R7 $R3 found
  StrCpy $R7 $R1 1 ; - optimization can be removed if U know len needle=1
  StrCpy $R2 "$R2$R7"
  StrCpy $R1 $R1 $R6 1
  StrCmp $R1 "" done loop
found:
  StrCpy $R2 "$R2$R4"
  StrCpy $R1 $R1 $R6 $R5
  StrCmp $R1 "" done loop
done:
  StrCpy $R3 $R2
  Pop $R7
  Pop $R6
  Pop $R5
  Pop $R2
  Pop $R1
  Pop $R4
  Exch $R3
FunctionEnd

Function WriteToolchainProperties
    ; Writes the toolchain properties for netbeans.  Won't overwrite existing
    ; config file, so if Netbeans has already been installed, this will need to be set up manually
    SetOutPath "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd"
    
    SetShellVarContext current
    
    StrCpy "$TempFile" "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd\remote.properties"
    IfFileExists "$TempFile" continue 0
    File remote.properties
    
    continue: 
    StrCpy "$TempFile" "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd\toolchain.properties"
    
    IfFileExists "$TempFile" toolchainExists 0
    File toolchain.properties
     
    ;C:\\Particle\\Toolchain\\GCC-ARM
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.setDirectory.0` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\bin\\arm-none-eabi-gcc.exe
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\bin\arm-none-eabi-gcc.exe"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolPath.0.0` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\bin\\arm-none-eabi-g++.exe
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\bin\arm-none-eabi-g++.exe"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolPath.0.1` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\bin\\arm-none-eabi-as.exe
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\bin\arm-none-eabi-as.exe"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolPath.0.3` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\Make\\bin\\make.exe
    StrCpy "$TempString" "$INSTDIR\Toolchain\Make\bin\make.exe"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolPath.0.4` `$0` $R0
      
    ;C:\\Particle\\Toolchain\\GCC-ARM\\lib\\gcc\\arm-none-eabi\\4.9.3\\include
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\lib\gcc\arm-none-eabi\4.9.3\include"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.0.systemIncludes.0` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\lib\\gcc\\arm-none-eabi\\4.9.3\\include-fixed
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\lib\gcc\arm-none-eabi\4.9.3\include-fixed"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.0.systemIncludes.1` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include"
    ${StrReplace}  '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.0.systemIncludes.2` `$0` $R0
    
        
    ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include\\c++\\4.9.3
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include\c++\4.9.3"
    ${StrReplace}  '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.0` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include\\c++\\4.9.3\\arm-none-eabi
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include\c++\4.9.3\arm-non-eabi"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.1` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include\\c++\\4.9.3\\backward
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include\c++\4.9.3\backward"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.2` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\lib\\gcc\\arm-none-eabi\\4.9.3\\include
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\lib\gcc\arm-non-eabi\4.9.3\include"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.3` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\lib\\gcc\\arm-none-eabi\\4.9.3\\include-fixed
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\lib\gcc\arm-non-eabi\4.9.3\include-fixed"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.4` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.5` `$0` $R0
    
    toolchainExists:
    SetOutPath "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd\modelimpl\RepositoryUpdater"
    StrCpy "$TempFile" "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd\modelimpl\RepositoryUpdater\cnd.properties"
    
    IfFileExists "$TempFile" endFunc 0
    File cnd.properties
    endFunc:
FunctionEnd
    
    
    
    

    
