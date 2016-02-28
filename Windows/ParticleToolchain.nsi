!include MUI2.nsh
SetCompressor /solid lzma

!define PRODUCT_NAME "Particle Toolchain Installer"
!define SHORT_NAME "ParticleToolchainInstaller"


; The name of the installer
Name "${PRODUCT_NAME}"
!include 'LogicLib.nsh'
!include 'Sections.nsh'
!include 'TextFunc.nsh'
;~ !include "DotNetChecker.nsh"
!include 'x64.nsh'
!insertmacro VersionCompare
!insertmacro ConfigWrite
!define REG_PATH "Software\${SHORT_NAME}"

;FileExists is already part of LogicLib, but returns true for directories as well as files
!macro _FileExists2 _a _b _t _f
	!insertmacro _LOGICLIB_TEMP
	StrCpy $_LOGICLIB_TEMP "0"
	StrCmp `${_b}` `` +4 0 ;if path is not blank, continue to next check
	IfFileExists `${_b}` `0` +3 ;if path exists, continue to next check (IfFileExists returns true if this is a directory)
	IfFileExists `${_b}\*.*` +2 0 ;if path is not a directory, continue to confirm exists
	StrCpy $_LOGICLIB_TEMP "1" ;file exists
	;now we have a definitive value - the file exists or it does not
	StrCmp $_LOGICLIB_TEMP "1" `${_t}` `${_f}`
!macroend
!undef FileExists
!define FileExists `"" FileExists2`
!macro _DirExists _a _b _t _f
	!insertmacro _LOGICLIB_TEMP
	StrCpy $_LOGICLIB_TEMP "0"	
	StrCmp `${_b}` `` +3 0 ;if path is not blank, continue to next check
	IfFileExists `${_b}\*.*` 0 +2 ;if directory exists, continue to confirm exists
	StrCpy $_LOGICLIB_TEMP "1"
	StrCmp $_LOGICLIB_TEMP "1" `${_t}` `${_f}`
!macroend
!define DirExists `"" DirExists`

!macro IfKeyExists ROOT MAIN_KEY KEY
  Push $R0
  Push $R1
  Push $R2
 
  # XXX bug if ${ROOT}, ${MAIN_KEY} or ${KEY} use $R0 or $R1
 
  StrCpy $R1 "0" # loop index
  StrCpy $R2 "0" # not found
 
  ${Do}
    EnumRegKey $R0 ${ROOT} "${MAIN_KEY}" "$R1"
    ${If} $R0 == "${KEY}"
      StrCpy $R2 "1" # found
      ${Break}
    ${EndIf}
    IntOp $R1 $R1 + 1
  ${LoopWhile} $R0 != ""
 
  ClearErrors
 
  Exch 2
  Pop $R0
  Pop $R1
  Exch $R2
!macroend
 

!macro _StrReplaceConstructor ORIGINAL_STRING TO_REPLACE REPLACE_BY
  Push "${ORIGINAL_STRING}"
  Push "${TO_REPLACE}"
  Push "${REPLACE_BY}"
  Call StrRep
  Pop $0
!macroend
 
!define StrReplace '!insertmacro "_StrReplaceConstructor"'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!define JSON_ADDRESS "https://raw.githubusercontent.com/mumblepins/ParticleToolchainInstaller/master/sources.json"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ShowInstDetails show

; The file to write
OutFile "${SHORT_NAME}.exe"

XPStyle on
InstallColors /windows

; The default installation directory
Function .onInit

	; The default installation directory
    StrCpy "$INSTDIR" "$WINDIR" 2
    StrCpy "$INSTDIR" "$INSTDIR\Particle"
    
    Var /GLOBAL TempFile
    ;~ Var /GLOBAL TempString
    
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
    
    
FunctionEnd



; Registry key to check for directory (so if you install again, it will
; overwrite the old one automatically)
InstallDirRegKey HKLM "${REG_PATH}" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

;--------------------------------

; Pages

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

 
!insertmacro MUI_LANGUAGE "English"

;~ Page components
;~ Page directory
;~ Page instfiles
;~ 
;~ UninstPage uninstConfirm
;~ UninstPage instfiles

InstType "Full"
InstType "Building Only"
;~ InstType "Toolchain Only"
;~ InstType "CLI Only"



;--------------------------------

; The stuff to install


SectionGroup "Toolchain" SEC_Toolchain
    Section "Make" SEC_Make
        SectionIn 1 2
        AddSize 2263
        DetailPrint "Installing Make"

        Call InstallMake

        DetailPrint "Adding Path"
        Push "$INSTDIR\Toolchain\Make\bin"
        Call AddToPath
              
    SectionEnd
    
    Section "MinGW" SEC_MinGW
        SectionIn 1 2
        AddSize 441344
        DetailPrint "Installing MinGW"

        ; Set output path to the installation directory.
        SetOutPath $INSTDIR

        Call InstallMinGW

        DetailPrint "Adding Path"
        Push "$INSTDIR\Toolchain\MinGW"
        Call AddToPath
        Push "$INSTDIR\Toolchain\MinGW\msys\1.0\bin"
        Call AddToPath  
       
        
        
    SectionEnd
    
    Section "GCC ARM" SEC_GCC
        SectionIn 1 2
        AddSize 314368
        DetailPrint "Installing GCC ARM"

        ; Set output path to the installation directory.
        SetOutPath $INSTDIR

        Call InstallGccArm

        DetailPrint "Adding Path"
        Push "$INSTDIR\Toolchain\GCC-ARM\bin"
        Call AddToPath  
         
    SectionEnd
SectionGroupEnd

Section Git SEC_Git
    SectionIn 1 2
    AddSize 270336
    DetailPrint "Installing Git"
    Call InstallGit
    ReadEnvStr $R0 "PATH"
	StrCpy $R0 "$R0;$INSTDIR\Tools\Git\cmd"
    System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("PATH", R0).r0'
    ReadEnvStr $R0 "PATH"
    DetailPrint $R0
    
            
SectionEnd

SectionGroup "Particle Firmware" SEC_GRP1
    Section "Firmware" SEC_REQ1
		AddSize 117720
        SectionIn 1 2 RO
        ReadRegDWORD $0 HKLM "${REG_PATH}" "FirmwareCloned"
		IfErrors CloneFirmware 0
		${If} $0 = 1
			DetailPrint "Firmware already cloned; Not doing it again"
			Goto EndSection
		${Else}
			Goto CloneFirmware
		${EndIf}
		CloneFirmware:
		
        SetOutPath "$INSTDIR"
        DetailPrint "Git Clone Firmware"
        nsExec::ExecToLog "git clone https://github.com/spark/firmware"
        SetOutPath "$INSTDIR\firmware"
        nsExec::ExecToLog "git checkout latest"
        WriteRegDWORD HKLM ${REG_PATH} "FirmwareCloned" 1
        EndSection:
    SectionEnd
        
    Section "Netbeans Project" SEC_OPT1
		AddSize 200
        SectionIn 1
        
        ReadRegDWORD $0 HKLM "${REG_PATH}" "NetbeansProjectInstalled"
		IfErrors InstallNBProject 0
		${If} $0 = 1
			DetailPrint "NB Project already installed; Not doing it again"
			Goto EndSection
		${Else}
			Goto InstallNBProject
		${EndIf}
		InstallNBProject:
		SetOverwrite off
        SetOutPath "$INSTDIR\NBProjects\ParticleFirmware\nbproject"
        File configurations.xml
        File project.xml
        SetOutPath "$INSTDIR\NBProjects\ParticleFirmware\nbproject\private"
        File CodeAssistancePathMapper.properties
        File /oname=configurations.xml private_configurations.xml
        File private.xml
        File Core.properties
        File Launcher.properties
        SetOverwrite on
        WriteRegDWORD HKLM ${REG_PATH} "NetbeansProjectInstalled" 1
        EndSection:
    SectionEnd
    
    Section "" PRIVSEC_TOGGLESTATE1 ;hidden section to keep track of state
    SectionEnd
SectionGroupEnd

Section "Netbeans" SEC_Netbeans
		AddSize 248832
        SectionIn 1
        DetailPrint "Installing Netbeans"
        Call InstallNetbeans
SectionEnd

;~ SectionGroup "Netbeans (Install JDK if not installed)" SEC_GRP
    ;~ Section "Netbeans" SEC_REQ
		;~ AddSize 248832
        ;~ SectionIn 1 RO
        ;~ DetailPrint "Installing Netbeans"
        ;~ Call InstallNetbeans
        ;~ 
    ;~ SectionEnd
    ;~ 
    ;~ Section "Config" SEC_OPT
        ;~ SectionIn 1
        ;~ DetailPrint "Writing Netbeans Config"
        ;~ Call WriteToolchainProperties
    ;~ SectionEnd
    ;~ 
    ;~ Section "" PRIVSEC_TOGGLESTATE ;hidden section to keep track of state
    ;~ SectionEnd
;~ SectionGroupEnd

Section "Cygwin" SEC_Cygwin
    SectionIn 1
    AddSize 144384
    DetailPrint "Installing Cygwin"
    Call InstallCygwin
SectionEnd




Section
    ; Write the installation path into the registry
    WriteRegStr HKLM ${REG_PATH} "Install_Dir" "$INSTDIR"

    ; Write the uninstall keys for Windows
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SHORT_NAME}" "DisplayName" "${PRODUCT_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SHORT_NAME}" "UninstallString" '"$INSTDIR\uninstall-particle-toolchain.exe"'
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SHORT_NAME}" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SHORT_NAME}" "NoRepair" 1
    WriteUninstaller "uninstall-particle-toolchain.exe"
SectionEnd


LangString DESC_SEC_REQ1 ${LANG_ENGLISH} "git clone the Particle Firmware"
LangString DESC_SEC_OPT1 ${LANG_ENGLISH} "Netbeans Project for the firmware"
LangString DESC_Netbeans ${LANG_ENGLISH} "Netbeans (will also install JDK). Note: Will need to add compiler to Netbeans manually."
LangString DESC_Cygwin ${LANG_ENGLISH} "Cygwin. 'Get that Linux Feeling on Windows'  Needed for automagic Netbeans build. Note: Will need to add compiler to Netbeans manually."
LangString DESC_Toolchain ${LANG_ENGLISH} "The tools necessary to build the Particle Firmware"
LangString DESC_Make ${LANG_ENGLISH} "Make for Windows tool for buillding"
LangString DESC_MinGW ${LANG_ENGLISH} "MinGW for Windows"
LangString DESC_GCC ${LANG_ENGLISH} "GCC Toolchain"
LangString DESC_Git ${LANG_ENGLISH} "Git for cloning the Firmware"



!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_GRP1} $(DESC_SEC_REQ1)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_REQ1} $(DESC_SEC_REQ1)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_OPT1} $(DESC_SEC_OPT1)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_Netbeans} $(DESC_Netbeans)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_Cygwin} $(DESC_Cygwin)
  
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_Toolchain} $(DESC_Toolchain)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_Make} $(DESC_Make)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_MinGW} $(DESC_MinGW)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_GCC} $(DESC_GCC)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_Git} $(DESC_Git)
  
!insertmacro MUI_FUNCTION_DESCRIPTION_END


;--------------------------------

; Uninstaller

Section "Uninstall"

	; Uninstall NodeJS
	;nsExec::ExecToLog "msiexec /x{B716A4B0-5096-4132-A741-2D99CFF53207} /passive"
	; Uninstall Python
	;nsExec::ExecToLog "MsiExec.exe /x{E2B51919-207A-43EB-AE78-733F9C6797C2} /passive"
    ; Remove registry keys
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParticleToolchain"
    DeleteRegKey HKLM SOFTWARE\ParticleToolchain
    
    RMDir /r /REBOOTOK "$INSTDir\Toolchain"

	

	RMDir /r /REBOOTOK "$INSTDir\Tools\DFU-util"
    ; Remove files and uninstaller
    ;  Delete $INSTDIR\ParticleToolchain.nsi
    Delete $INSTDIR\uninstall.exe

   
    RMDir "$INSTDIR"
    Push "$INSTDIR\Toolchain\Make\bin"
    Call un.RemoveFromPath
    Push "$INSTDIR\Toolchain\GCC-ARM\bin"
    Call un.RemoveFromPath
    Push "$INSTDIR\Toolchain\MinGW"
    Call un.RemoveFromPath
    Push "$INSTDIR\Toolchain\MinGW\msys\1.0\bin"
    Call un.RemoveFromPath
    Push "$INSTDIR\Tools\DFU-util"
	Call un.RemoveFromPath
     
SectionEnd


Function .onSelChange
    !define /math SECFLAGS_SELRO ${SF_SELECTED} | ${SF_RO}
    ;~ ${IfNot} ${SectionIsSelected} ${PRIVSEC_TOGGLESTATE}
    ;~ ${AndIf} ${SectionIsReadOnly} ${SEC_REQ}
        ;~ !insertmacro ClearSectionFlag ${SEC_REQ} ${SECFLAGS_SELRO}
    ;~ ${EndIf}
    ;~ ${If} ${SectionIsSelected} ${SEC_OPT}
        ;~ !insertmacro SetSectionFlag ${SEC_REQ} ${SECFLAGS_SELRO} 
    ;~ ${Else}
        ;~ !insertmacro ClearSectionFlag ${SEC_REQ} ${SF_RO}
    ;~ ${EndIf}
    ;~ ${If} ${SectionIsSelected} ${SEC_REQ}
        ;~ !insertmacro SelectSection ${PRIVSEC_TOGGLESTATE}
    ;~ ${Else}
        ;~ !insertmacro UnselectSection ${PRIVSEC_TOGGLESTATE}
    ;~ ${EndIf}
    
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
	DetailPrint "Checking GCC Version Installed"
	ClearErrors
	ReadRegStr $0 HKLM "${REG_PATH}" "GCC_ARM_Version"
	IfErrors 0 CheckGCC_Ver
	goto  InstallGCCArmNow
	CheckGCC_Ver:
	${VersionCompare} $0 "$GCC_ARM_VER" $R0
    ${If} $R0 == 2
        DetailPrint "Need to update GCC ARM"
        goto InstallGCCArmNow
	${Else}
		goto EndFunc
    ${EndIf}
	
	InstallGCCArmNow:
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
     WriteRegStr HKLM "${REG_PATH}" "GCC_ARM_Version" "$GCC_ARM_VER"
	
    EndFunc:

FunctionEnd

Function InstallMake
    DetailPrint "Checking Make Version Installed"
	ClearErrors
	ReadRegStr $0 HKLM "${REG_PATH}" "Make_Version"
	IfErrors 0 CheckMakeVer
	goto  InstallMakeNow
	CheckMakeVer:
	${VersionCompare} $0 "$MAKE_BINARY_VER" $R0
    ${If} $R0 == 2
        DetailPrint "Need to update Make"
        goto InstallMakeNow
	${Else}
		goto EndFunc
    ${EndIf}
	
	InstallMakeNow:
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
    WriteRegStr HKLM "${REG_PATH}" "Make_Version" "$MAKE_BINARY_VER"
	
    EndFunc:
FunctionEnd

Function InstallMinGW
	DetailPrint "Checking MinGw Version Installed"
	ClearErrors
	ReadRegStr $0 HKLM "${REG_PATH}" "MinGW_Version"
	IfErrors 0 CheckminGW_Ver
	goto  InstallMinGWNow
	CheckminGW_Ver:
	${VersionCompare} $0 "$MINGW_VER" $R0
    ${If} $R0 == 2
        DetailPrint "Need to update MinGW"
        goto InstallMinGWNow
	${Else}
		goto EndFunc
    ${EndIf}
	
	InstallMinGWNow:
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
    WriteRegStr HKLM "${REG_PATH}" "MinGW_Version" "$MINGW_VER"
	
    EndFunc:
FunctionEnd

Function InstallGit
	DetailPrint "Checking Git Version Installed"
	ClearErrors
	ReadRegStr $0 HKLM "${REG_PATH}" "Git_Version"
	IfErrors 0 CheckGit_Ver
	goto  InstallGitNow
	CheckGit_Ver:
	${VersionCompare} $0 "$GIT_VER" $R0
    ${If} $R0 == 2
        DetailPrint "Need to update Git"
        goto InstallGitNow
	${Else}
		goto EndFunc
    ${EndIf}
	
	InstallGitNow:
	DetailPrint "Downloading Git"

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
	WriteRegStr HKLM "${REG_PATH}" "Git_Version" "$GIT_VER"
	
    EndFunc:
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
    
    DetailPrint "Checking Netbeans Version Installed"
	ClearErrors
	ReadRegStr $0 HKLM "${REG_PATH}" "Netbeans_Version"
	IfErrors 0 CheckNetbeans_Ver
	goto  InstNetbeans
	CheckNetbeans_Ver:
	${VersionCompare} $0 "$NETBEANS_VER" $R0
    ${If} $R0 == 2
        DetailPrint "Need to update Netbeans"
        goto InstNetbeans
	${Else}
		goto EndFunc
    ${EndIf}
	
	InstNetbeans:
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
     WriteRegStr HKLM "${REG_PATH}" "Netbeans_Version" "$NETBEANS_VER"
	
    EndFunc:
    
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
	DetailPrint "Checking Cygwin Version Installed"
	ClearErrors
	ReadRegStr $0 HKLM "${REG_PATH}" "Cygwin_Version"
	IfErrors 0 CheckCygwin_Ver
	goto  InstallCygwin
	CheckCygwin_Ver:
	${VersionCompare} $0 "$CYGWIN_VER" $R0
    ${If} $R0 == 2
        DetailPrint "Need to update Cygwin"
        goto InstallCygwin
	${Else}
		goto EndFunc
    ${EndIf}
	
	InstallCygwin:
    DetailPrint "Installing Cygwin"
    CreateDirectory "$INSTDIR\Tools\Cygwin"
    StrCpy "$TempFile" "$INSTDIR\Tools\Cygwin\Cygwin_setup.exe"
    
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
     WriteRegStr HKLM "${REG_PATH}" "Cygwin_Version" "$CYGWIN_VER"
	
    EndFunc:
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



;~ Function StrRep
  ;~ Exch $R4 ; $R4 = Replacement String
  ;~ Exch
  ;~ Exch $R3 ; $R3 = String to replace (needle)
  ;~ Exch 2
  ;~ Exch $R1 ; $R1 = String to do replacement in (haystack)
  ;~ Push $R2 ; Replaced haystack
  ;~ Push $R5 ; Len (needle)
  ;~ Push $R6 ; len (haystack)
  ;~ Push $R7 ; Scratch reg
  ;~ StrCpy $R2 ""
  ;~ StrLen $R5 $R3
  ;~ StrLen $R6 $R1
;~ loop:
  ;~ StrCpy $R7 $R1 $R5
  ;~ StrCmp $R7 $R3 found
  ;~ StrCpy $R7 $R1 1 ; - optimization can be removed if U know len needle=1
  ;~ StrCpy $R2 "$R2$R7"
  ;~ StrCpy $R1 $R1 $R6 1
  ;~ StrCmp $R1 "" done loop
;~ found:
  ;~ StrCpy $R2 "$R2$R4"
  ;~ StrCpy $R1 $R1 $R6 $R5
  ;~ StrCmp $R1 "" done loop
;~ done:
  ;~ StrCpy $R3 $R2
  ;~ Pop $R7
  ;~ Pop $R6
  ;~ Pop $R5
  ;~ Pop $R2
  ;~ Pop $R1
  ;~ Pop $R4
  ;~ Exch $R3
;~ FunctionEnd
;~ 
;~ Function WriteToolchainProperties
	;~ SetOverWrite off
    ;~ ; Writes the toolchain properties for netbeans.  Won't overwrite existing
    ;~ ; config file, so if Netbeans has already been installed, this will need to be set up manually
    ;~ SetOutPath "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd"
    ;~ 
    ;~ SetShellVarContext current
    ;~ 
    ;~ StrCpy "$TempFile" "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd\remote.properties"
    ;~ IfFileExists "$TempFile" continue 0
    ;~ File remote.properties
    ;~ 
    ;~ continue: 
    ;~ StrCpy "$TempFile" "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd\toolchain.properties"
    ;~ 
    ;~ IfFileExists "$TempFile" toolchainExists 0
    ;~ File toolchain.properties
     ;~ 
    ;~ ;C:\\Particle\\Toolchain\\GCC-ARM
    ;~ StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM"
    ;~ ${StrReplace} '$TempString' '\' '\\'
    ;~ ${ConfigWrite} "$TempFile" `=csm.localhost.setDirectory.0` `$0` $R0
    ;~ 
    ;~ ;C:\\Particle\\Toolchain\\GCC-ARM\\bin\\arm-none-eabi-gcc.exe
    ;~ StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\bin\arm-none-eabi-gcc.exe"
    ;~ ${StrReplace} '$TempString' '\' '\\'
    ;~ ${ConfigWrite} "$TempFile" `=csm.localhost.toolPath.0.0` `$0` $R0
    ;~ 
    ;~ ;C:\\Particle\\Toolchain\\GCC-ARM\\bin\\arm-none-eabi-g++.exe
    ;~ StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\bin\arm-none-eabi-g++.exe"
    ;~ ${StrReplace} '$TempString' '\' '\\'
    ;~ ${ConfigWrite} "$TempFile" `=csm.localhost.toolPath.0.1` `$0` $R0
    ;~ 
    ;~ ;C:\\Particle\\Toolchain\\GCC-ARM\\bin\\arm-none-eabi-as.exe
    ;~ StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\bin\arm-none-eabi-as.exe"
    ;~ ${StrReplace} '$TempString' '\' '\\'
    ;~ ${ConfigWrite} "$TempFile" `=csm.localhost.toolPath.0.3` `$0` $R0
    ;~ 
    ;~ ;C:\\Particle\\Toolchain\\Make\\bin\\make.exe
    ;~ StrCpy "$TempString" "$INSTDIR\Toolchain\Make\bin\make.exe"
    ;~ ${StrReplace} '$TempString' '\' '\\'
    ;~ ${ConfigWrite} "$TempFile" `=csm.localhost.toolPath.0.4` `$0` $R0
      ;~ 
    ;~ ;C:\\Particle\\Toolchain\\GCC-ARM\\lib\\gcc\\arm-none-eabi\\4.9.3\\include
    ;~ StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\lib\gcc\arm-none-eabi\$GCC_ARM_VER\include"
    ;~ ${StrReplace} '$TempString' '\' '\\'
    ;~ ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.0.systemIncludes.0` `$0` $R0
    ;~ 
    ;~ ;C:\\Particle\\Toolchain\\GCC-ARM\\lib\\gcc\\arm-none-eabi\\4.9.3\\include-fixed
    ;~ StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\lib\gcc\arm-none-eabi\$GCC_ARM_VER\include-fixed"
    ;~ ${StrReplace} '$TempString' '\' '\\'
    ;~ ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.0.systemIncludes.1` `$0` $R0
    ;~ 
    ;~ ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include
    ;~ StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include"
    ;~ ${StrReplace}  '$TempString' '\' '\\'
    ;~ ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.0.systemIncludes.2` `$0` $R0
    ;~ 
        ;~ 
    ;~ ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include\\c++\\4.9.3
    ;~ StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include\c++\$GCC_ARM_VER"
    ;~ ${StrReplace}  '$TempString' '\' '\\'
    ;~ ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.0` `$0` $R0
    ;~ 
    ;~ ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include\\c++\\4.9.3\\arm-none-eabi
    ;~ StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include\c++\$GCC_ARM_VER\arm-non-eabi"
    ;~ ${StrReplace} '$TempString' '\' '\\'
    ;~ ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.1` `$0` $R0
    ;~ 
    ;~ ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include\\c++\\4.9.3\\backward
    ;~ StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include\c++\$GCC_ARM_VER\backward"
    ;~ ${StrReplace} '$TempString' '\' '\\'
    ;~ ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.2` `$0` $R0
    ;~ 
    ;~ ;C:\\Particle\\Toolchain\\GCC-ARM\\lib\\gcc\\arm-none-eabi\\4.9.3\\include
    ;~ StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\lib\gcc\arm-non-eabi\$GCC_ARM_VER\include"
    ;~ ${StrReplace} '$TempString' '\' '\\'
    ;~ ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.3` `$0` $R0
    ;~ 
    ;~ ;C:\\Particle\\Toolchain\\GCC-ARM\\lib\\gcc\\arm-none-eabi\\4.9.3\\include-fixed
    ;~ StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\lib\gcc\arm-non-eabi\$GCC_ARM_VER\include-fixed"
    ;~ ${StrReplace} '$TempString' '\' '\\'
    ;~ ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.4` `$0` $R0
    ;~ 
    ;~ ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include
    ;~ StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include"
    ;~ ${StrReplace} '$TempString' '\' '\\'
    ;~ ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.5` `$0` $R0
    ;~ 
    ;~ toolchainExists:
    ;~ SetOutPath "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd\modelimpl\RepositoryUpdater"
    ;~ StrCpy "$TempFile" "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd\modelimpl\RepositoryUpdater\cnd.properties"
    ;~ 
    ;~ IfFileExists "$TempFile" endFunc 0
    ;~ File cnd.properties
    ;~ endFunc:
    ;~ 
    ;~ SetOverwrite on
;~ FunctionEnd
    
    
    
    

    
