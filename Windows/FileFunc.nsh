/*
_____________________________________________________________________________

                       File Functions Header v1.4
_____________________________________________________________________________

 2005 Shengalts Aleksander (Shengalts@mail.ru)

 Copy "FileFunc.nsh" to NSIS include directory
 Usually "C:\Program Files\NSIS\Include"

 Usage in script:
 1. !include "FileFunc.nsh"
 2. !insertmacro FileFunction
 3. [Section|Function]
      ${FileFunction} "Param1" "Param2" "..." $var
    [SectionEnd|FunctionEnd]


 FileFunction=[Locate|GetSize|GetDrives|GetTime|GetExeName|GetExePath|
               GetParameters|GetBaseName|GetFileExt|GetFileVersion|
               VersionCompare|DirState|RefreshShellIcons]

 un.FileFunction=[un.Locate|un.GetSize|un.GetDrives|un.GetTime|
                  un.GetExeName|un.GetExePath|un.GetParameters|
                  un.GetBaseName|un.GetFileExt|un.GetFileVersion|
                  un.VersionCompare|un.DirState|un.RefreshShellIcons]

____________________________________________________________________________

                              Locate v1.4
____________________________________________________________________________

2004 Shengalts Aleksander (Shengalts@mail.ru)


Find files, directories and empty directories with mask and size options.


Syntax:

${Locate} "[Path]" "[Options]" "Function"

"[Path]"      ; [Path]
              ;     Disk or Directory
"[Options]"   ; /L=[FD|F|D|DE|FDE]
              ;     /L=FD    - Locate Files and Directories (default)
              ;     /L=F     - Locate Files only
              ;     /L=D     - Locate Directories only
              ;     /L=DE    - Locate Empty Directories only
              ;     /L=FDE   - Locate Files and Empty Directories
              ; /M=[mask]
              ;     /M=*.*         - Locate all (default)
              ;     /M=*.doc       - Locate Work.doc, 1.doc ...
              ;     /M=Pho*        - Locate PHOTOS, phone.txt ...
              ;     /M=win???.exe  - Locate winamp.exe, winver.exe ...
              ;     /M=winamp.exe  - Locate winamp.exe only
              ; /S=No:No[B|K|M|G]
              ;     /S=      - Don't locate file size (faster) (default)
              ;     /S=0:0B  - Locate only files of 0 Bytes exactly
              ;     /S=5:9K  - Locate only files of 5 to 9 Kilobytes
              ;     /S=:10M  - Locate only files of 10 Megabyte or less
              ;     /S=1G    - Locate only files of 1 Gigabyte or more
              ; /G=[1|0]
              ;     /G=1     - Locate with subdirectories (default)
              ;     /G=0     - Locate without subdirectories
"Function"    ; Callback function then found

Function "Function"
	; $R9    "path\name"
	; $R8    "path"
	; $R7    "name"
	; $R6    "size"  ($R6="" if directory, $R6="0" if file with /S=)


	; $R0-$R5  are not used (save data in them).
	; ...


	Push $var    ; If $var=StopLocate Then exit from function
FunctionEnd


Note:
-Error flag if disk or directory isn't exist
-Error flag if syntax error




Example (Find one file):
Section
	${Locate} "C:\ftp" "/L=F /M=RPC DCOM.rar /S=1K" "Example1"
	; 'RPC DCOM.rar' file in 'C:\ftp' with size 1 Kb or more

	IfErrors 0 +2
	MessageBox MB_OK "Error" IDOK +2
	MessageBox MB_OK "$$R0=$R0"
SectionEnd

Function Example1
	StrCpy $R0 $R9
	; $R0 now contain: "C:\ftp\files\RPC DCOM.rar"

	MessageBox MB_YESNO '$R0$\n$\nFind next?' IDYES +2
	StrCpy $0 StopLocate
	Push $0
FunctionEnd



Example (Write founded in text file):
Section
	GetTempFileName $R0
	FileOpen $R1 $R0 w
	${Locate} "C:\ftp" "/S=:2M /G=0" "Example2"
	; folders and all files with size 2 Mb or less
        ; don't scan subdirectories
	FileClose $R1

	IfErrors 0 +2
	MessageBox MB_OK "Error" IDOK +2
	Exec '"notepad.exe" "$R0"'
SectionEnd

Function Example2
	StrCmp $R6 '' 0 +3
	FileWrite $R1 "Directory=$R9$\r$\n"
	goto +2
	FileWrite $R1 "File=$R9  Size=$R6 Mb$\r$\n"
	Push $0
FunctionEnd



Example (Write founded in INI file):
Section
	GetTempFileName $R0
	${Locate} "C:\ftp" "/L=F /S=0K" "Example3"
	; all files in 'C:\ftp' with size detect in Kb

	IfErrors 0 +2
	MessageBox MB_OK "Error" IDOK +2
	Exec '"notepad.exe" "$R0"'
SectionEnd

Function Example3
	WriteINIStr $R0 "$R8" "$R7" "$R6 Kb"
	Push $0
FunctionEnd



Example (Delete empty directories):
Section
	StrCpy $R2 0
	StrCpy $R3 0

	loop:
	StrCpy $R1 0
	${Locate} "C:\ftp" "/L=DE" "Example4"
	IntOp $R3 $R3 + 1
	IntOp $R2 $R2 + $R1
	StrCmp $R0 StopLocate +2
	StrCmp $R1 0 0 loop

	IfErrors 0 +2
	MessageBox MB_OK 'error' IDOK +2
	MessageBox MB_OK '$R2 directories were removed$\n$R3 loops'
SectionEnd

Function Example4
	MessageBox MB_YESNOCANCEL 'Delete empty "$R9"?' IDNO end IDCANCEL cancel
	RMDir $R9
	IntOp $R1 $R1 + 1
	goto end

	cancel:
	StrCpy $R0 StopLocate

	end:
	Push $R0
FunctionEnd



Example (Move all files into one folder):
Section
	StrCpy $R0 "C:\ftp"   ;Directory move from
	StrCpy $R1 "C:\ftp2"  ;Directory move into

	StrCpy $R2 0
	StrCpy $R3 0
	${Locate} "$R0" "/L=F" "Example5"

	IfErrors 0 +2
	MessageBox MB_OK 'error' IDOK +4
	StrCmp $R3 0 0 +2
	MessageBox MB_OK '$R2 files were moved' IDOK +2
	MessageBox MB_OK '$R2 files were moved$\n$R3 files were NOT moved'
SectionEnd

Function Example5
	StrCmp $R8 $R1 +6
	IfFileExists '$R1\$R7' +4
	Rename $R9 '$R1\$R7'
	IntOp $R2 $R2 + 1
	goto +2
	IntOp $R3 $R3 + 1
	Push $0
FunctionEnd



Example (Copy files with log):
Section
	StrCpy $R0 "C:\ftp"   ;Directory copy from
	StrCpy $R1 "C:\ftp2"  ;Directory copy into
	StrLen $R2 $R0

	GetTempFileName $0
	FileOpen $R3 $0 w
	${Locate} "$R0" "/L=FDE" "Example6"
	FileClose $R3

	IfErrors 0 +2
	MessageBox MB_OK 'error'

	Exec '"notepad.exe" "$0"'     ;view log
SectionEnd

Function Example6
	StrCpy $1 $R8 '' $R2

	StrCmp $R6 '' 0 +3
	CreateDirectory '$R1$1\$R7'
	goto end
	CreateDirectory '$R1$1'
	CopyFiles /SILENT $R9 '$R1$1'

	IfFileExists '$R1$1\$R7' 0 +3
	FileWrite $R3 "-old:$R9  -new:$R1$1\$R7  -success$\r$\n"
	goto +2
	FileWrite $R3 "-old:$R9  -new:$R1$1\$R7  -failed$\r$\n"

	end:
	Push $0
FunctionEnd



Example (Recreate directory structure):
Section
	StrCpy $R0 "C:\ftp"     ;Directory structure from
	StrCpy $R1 "C:\ftp2"    ;Directory structure into
	StrLen $R2 $R0

	${Locate} "$R0" "/L=D" "Example7"

	IfErrors 0 +2
	MessageBox MB_OK 'error'
SectionEnd

Function Example7
	StrCpy $1 $R9 '' $R2
	CreateDirectory '$R1$1'

	Push $0
FunctionEnd

____________________________________________________________________________

                            GetSize v1.8
____________________________________________________________________________

2004 Shengalts Aleksander (Shengalts@mail.ru)

Thanks KiCHiK (Function "FindFiles")

Features:
1. Find the size of a file, files mask or directory
2. Find the sum of the files, directories and subdirectories

Syntax:

${GetSize} "[Path]" "[Options]" $var1 $var2 $var3

"[Path]"      ; [Path]
              ;     Disk or Directory
"[Options]"   ; /M=[mask]
              ;     /M=*.*         - Find all (default)
              ;     /M=*.doc       - Find Work.doc, 1.doc ...
              ;     /M=Pho*        - Find PHOTOS, phone.txt ...
              ;     /M=win???.exe  - Find winamp.exe, winver.exe ...
              ;     /M=winamp.exe  - Find winamp.exe only
              ; /S=No:No[B|K|M|G]
              ;     /S=      - Don't find file size (faster) (default)
              ;     /S=0:0B  - Find only files of 0 Bytes exactly
              ;     /S=5:9K  - Find only files of 5 to 9 Kilobytes
              ;     /S=:10M  - Find only files of 10 Megabyte or less
              ;     /S=1G    - Find only files of 1 Gigabyte or more
              ; /G=[1|0]
              ;     /G=1     - Find with subdirectories (default)
              ;     /G=0     - Find without subdirectories
              ;
$var1         ;   Size
$var2         ;   Sum of files
$var3         ;   Sum of directories


Note:
-Error flag if disk or directory isn't exist
-Error flag if syntax error



Example (1):
Section
	; Find file size "C:\WINDOWS\Explorer.exe" in kilobytes

	${GetSize} "C:\WINDOWS" "/M=Explorer.exe /S=0K /G=0" $0 $1 $2
	; $0="220" Kb
	; $1="1"   files
	; $2=""    directories

	IfErrors 0 +2
	MessageBox MB_OK "Error"
SectionEnd

Example (2):
Section
	; Find folder size "C:\Installs\Reanimator\Drivers" in megabytes

	${GetSize} "C:\Installs\Reanimator\Drivers" "/S=0M" $0 $1 $2
	; $0="132" Mb
	; $1="555" files
	; $2="55"  directories

	IfErrors 0 +2
	MessageBox MB_OK "Error"
SectionEnd

Example (3):
Section
	; Find sum of files and folders "C:\WINDOWS" (no subfolders)

	${GetSize} "C:\WINDOWS" "/G=0" $0 $1 $2
	; $0=""    size
	; $1="253" files
	; $2="46"  directories

	IfErrors 0 +2
	MessageBox MB_OK "Error"
SectionEnd

____________________________________________________________________________

                            GetDrives v1.1
____________________________________________________________________________

2005 Shengalts Aleksander (Shengalts@mail.ru)

Thanks deguix (Based on his idea of Function "DetectDrives" 2003-10-11)


Find all available drives in the system.


Syntax:

${GetDrives} "[Option]" "Function"

"[Option]"      ; [FDD+HDD+CDROM+NET+RAM]
                ;   FDD    Floppy Disk Drives
                ;   HDD    Hard Disk Drives 
                ;   CDROM  CD-ROM Drives
                ;   NET    Network Drives
                ;   RAM    RAM Disk Drives
                ;
                ; []
                ;   Find all drives by letter
                ;
"Function"      ; Callback function then found

Function "Function"
	; $9    "drive letter"  (a:\ c:\ ...)
	; $8    "drive type"    (FDD HDD ...)


	; $R0-$R9  are not used (save data in them).
	; ...


	Push $var    ; If $var=Stop Then exit from function
FunctionEnd



Example1:
Section
	${GetDrives} "FDD+CDROM" "Example1"
SectionEnd

Function Example1
	MessageBox MB_OK "$9  ($8 Drive)"

	Push $0
FunctionEnd



Example2:
Section
	${GetDrives} "" "Example2"
SectionEnd

Function Example2
	MessageBox MB_OK "$9  ($8 Drive)"

	Push $0
FunctionEnd



Example3 (Get type of drive):
Section
	StrCpy $R0 "D:\"      ;Drive letter
	StrCpy $R1 "invalid"

	${GetDrives} "" "Example3"

	MessageBox MB_OK "Type of drive $R0 is $R1"
SectionEnd

Function Example3
	StrCmp $9 $R0 0 +3
	StrCpy $R1 $8
	StrCpy $0 Stop

	Push $0
FunctionEnd

____________________________________________________________________________

                            GetTime v1.1
____________________________________________________________________________

2004 Shengalts Aleksander (Shengalts@mail.ru)

Thanks Takhir (Script "StatTest") and deguix (Function "FileModifiedDate")


Features:
1. Get local time
2. Get file time (access, creation and modification)

Syntax:

${GetTime} "[File]" "[Option]" $var1 $var2 $var3 $var4 $var5 $var6 $var7

"[File]"        ; [File]
                ;   Ignored if "L"
"[Option]"      ; [Options]
                ;   L   Local time
                ;   A   last Access file time
                ;   C   Creation file time
                ;   M   Modification file time
                ;
$var1           ; day
$var2           ; month
$var3           ; year
$var4           ; day of week name
$var5           ; hour
$var6           ; minute
$var7           ; seconds


Note:
-Error flag if file isn't exist
-Error flag if syntax error



Example (Get local time):
Section
	${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
	; $0="13"      day
	; $1="12"      month
	; $2="2004"    year
	; $3="Monday"  day of week name
	; $4="16"      hour
	; $5="05"      minute
	; $6="50"      seconds

	IfErrors 0 +2
	MessageBox MB_OK "Error"
SectionEnd


Example (Get file time):
Section
	${GetTime} "$WINDIR\Explorer.exe" "C" $0 $1 $2 $3 $4 $5 $6
	; $0="12"       day
	; $1="10"       month
	; $2="2004"     year
	; $3="Tuesday"  day of week name
	; $4="2"        hour
	; $5="32"       minute
	; $6="03"       seconds

	IfErrors 0 +2
	MessageBox MB_OK "Error" IDOK +2
	MessageBox MB_OK 'Date=$0/$1/$2 ($3)$\nTime=$4:$5:$6'
SectionEnd

____________________________________________________________________________

                            GetExeName
____________________________________________________________________________

2004 Shengalts Aleksander (Shengalts@mail.ru)


Get installer filename (also valid case for Windows 9X).


Syntax:
${GetExeName} $var

$var    ; installer filename


Example:
Section
	${GetExeName} $R0
	; $R0="C:\ftp\program.exe"
SectionEnd

____________________________________________________________________________

                            GetExePath
____________________________________________________________________________

2004 Shengalts Aleksander (Shengalts@mail.ru)


Get installer pathname ($EXEDIR with valid case for Windows 9X).


Syntax:
${GetExePath} $var

$var    ; installer pathname


Example:
Section
	${GetExePath} $R0
	; $R0="C:\ftp"
SectionEnd

____________________________________________________________________________

                            GetParameters
____________________________________________________________________________


Get command line parameters.


Syntax:

${GetParameters} $var


Example:
Section
	${GetParameters} $R0
	; $R0 now contain: "[parameters]"
SectionEnd

____________________________________________________________________________

                            GetBaseName
____________________________________________________________________________

2005 Shengalts Aleksander (Shengalts@mail.ru)

Thanks comperio (Based on his idea of Function "GetBaseName" 2005-01-28)


Get file name without extension.


Syntax:
${GetBaseName} "[FileString]" $var

"[FileString]"      ; [FileString]
                    ;   File name string
                    ;
$var                ; base name


Example:
Section
	${GetBaseName} "C:\ftp\program.exe" $R0
	; $R0="program"
SectionEnd

____________________________________________________________________________

                            GetFileExt
____________________________________________________________________________

Written by opher 2004-01-15


Get extention of file.


Syntax:
${GetFileExt} "[FileString]" $var

"[FileString]"      ; [FileString]
                    ;   File name string
                    ;
$var                ; extention


Example:
Section
	${GetFileExt} "C:\ftp\program.exe" $R0
	; $R0="exe"
SectionEnd

____________________________________________________________________________

                            GetFileVersion
____________________________________________________________________________


Gets the version information from executable file.


Syntax:
${GetFileVersion} "[Executable]" $var

"[Executable]"      ; [Executable]
                    ;   Executable file (*.exe *.dll ...)
                    ;
$var                ; version

Note:
-Error flag if file isn't exist
-Error flag if file isn't contain version information


Example:
Section
	${GetFileVersion} "C:\ftp\program.exe" $R0
	; $R0="1.1.0.12"
SectionEnd

____________________________________________________________________________

                            VersionCompare v1.0
____________________________________________________________________________

2005 Shengalts Aleksander (Shengalts@mail.ru)

Thanks Afrow UK (Based on his Function "VersionCheckNew2" 2005-01-24)


Compare version numbers.


Syntax:
${VersionCompare} "[Version1]" "[Version2]" $var

"[Version1]"        ; [Version1]
                    ;   First version
"[Version2]"        ; [Version2]
                    ;   Second version
                    ;
$var                ; Result:
                    ;    $var=0  Versions are equal
                    ;    $var=1  Version1 is newer
                    ;    $var=2  Version2 is newer


Example:
Section
	${VersionCompare} "1.1.1.9" "1.1.1.01" $R0
	; $R0="1"
SectionEnd

____________________________________________________________________________

                            DirState
____________________________________________________________________________

2004 Shengalts Aleksander (Shengalts@mail.ru)


Check directory full, empty or not exist.


Syntax:
${DirState} "[path]" $var

"[path]"      ; [path]
              ;   Directory
              ;
$var          ; $var=0  (empty)
              ; $var=1  (full)
              ; $var=-1 (directory not found)


Example:
Section
	${DirState} "$TEMP" $R0
	; $R0="1"  directory is full
SectionEnd

____________________________________________________________________________

                            RefreshShellIcons
____________________________________________________________________________

Written by jerome tremblay 2003-04-16


After changing file associations, you can call this macro
to refresh the shell immediatly.


Syntax:
${RefreshShellIcons}


Example:
Section
	WriteRegStr HKCR "Winamp.File\DefaultIcon" "" "$PROGRAMFILES\Winamp\WINAMP.EXE,2"

	${RefreshShellIcons}
SectionEnd
*/


;_____________________________________________________________________________
;
;                                   Macros
;_____________________________________________________________________________
;
!define _UNFILE

!macro LocateCall _PATH _OPTIONS _FUNC
	Push $0
	Push `${_PATH}`
	Push `${_OPTIONS}`
	GetFunctionAddress $0 `${_FUNC}`
	Push `$0`
	Call Locate
	Pop $0
!macroend

!macro GetSizeCall _PATH _OPTION _RESULT1 _RESULT2 _RESULT3
	Push `${_PATH}`
	Push `${_OPTION}`
	Call GetSize
	Pop ${_RESULT1}
	Pop ${_RESULT2}
	Pop ${_RESULT3}
!macroend

!macro GetDrivesCall _DRV _FUNC
	Push $0
	Push `${_DRV}`
	GetFunctionAddress $0 `${_FUNC}`
	Push `$0`
	Call GetDrives
	Pop $0
!macroend

!macro GetTimeCall _FILE _OPTION _RESULT1 _RESULT2 _RESULT3 _RESULT4 _RESULT5 _RESULT6 _RESULT7
	Push `${_FILE}`
	Push `${_OPTION}`
	Call GetTime
	Pop ${_RESULT1}
	Pop ${_RESULT2}
	Pop ${_RESULT3}
	Pop ${_RESULT4}
	Pop ${_RESULT5}
	Pop ${_RESULT6}
	Pop ${_RESULT7}
!macroend

!macro GetExeNameCall _RESULT
	Call GetExeName
	Pop ${_RESULT}
!macroend

!macro GetExePathCall _RESULT
	Call GetExePath
	Pop ${_RESULT}
!macroend

!macro GetParametersCall _RESULT
	Call GetParameters
	Pop ${_RESULT}
!macroend

!macro GetBaseNameCall _FILESTRING _RESULT
	Push `${_FILESTRING}`
	Call GetBaseName
	Pop ${_RESULT}
!macroend

!macro GetFileExtCall _FILESTRING _RESULT
	Push `${_FILESTRING}`
	Call GetFileExt
	Pop ${_RESULT}
!macroend

!macro GetFileVersionCall _FILE _RESULT
	Push `${_FILE}`
	Call GetFileVersion
	Pop ${_RESULT}
!macroend

!macro VersionCompareCall _VER1 _VER2 _RESULT
	Push `${_VER1}`
	Push `${_VER2}`
	Call VersionCompare
	Pop ${_RESULT}
!macroend

!macro DirStateCall _PATH _RESULT
	Push `${_PATH}`
	Call DirState
	Pop ${_RESULT}
!macroend

!macro RefreshShellIconsCall
	Call RefreshShellIcons
!macroend

!macro Locate
	!ifndef ${_UNFILE}Locate
		!define ${_UNFILE}Locate `!insertmacro ${_UNFILE}LocateCall`

		Function ${_UNFILE}Locate
			Exch $2
			Exch
			Exch $1
			Exch
			Exch 2
			Exch $0
			Exch 2
			Push $3
			Push $4
			Push $5
			Push $6
			Push $7
			Push $8
			Push $9
			Push $R6
			Push $R7
			Push $R8
			Push $R9
			ClearErrors

			StrCpy $R9 $0 '' -1
			StrCmp $R9 '\' 0 +3
			StrCpy $0 $0 -1
			goto -3
			IfFileExists '$0\*.*' 0 error

			StrCpy $3 ''
			StrCpy $4 ''
			StrCpy $5 ''
			StrCpy $6 ''
			StrCpy $8 0

			option:
			StrCpy $R9 $1 1
			StrCpy $1 $1 '' 1
			StrCmp $R9 ' ' -2
			StrCmp $R9 '' sizeset
			StrCmp $R9 '/' 0 -4

			StrCpy $9 0
			StrCpy $R9 $1 1 $9
			StrCmp $R9 '' +4
			StrCmp $R9 '/' +3
			IntOp $9 $9 + 1
			goto -4
			StrCpy $8 $1 $9
			StrCpy $8 $8 '' 2
			StrCpy $R9 $8 '' -1
			StrCmp $R9 ' ' 0 +3
			StrCpy $8 $8 -1
			goto -3
			StrCpy $R9 $1 2
			StrCpy $1 $1 '' $9

			StrCmp $R9 'L=' 0 mask
			StrCpy $3 $8
			StrCmp $3 '' +6
			StrCmp $3 'FD' +5
			StrCmp $3 'F' +4
			StrCmp $3 'D' +3
			StrCmp $3 'DE' +2
			StrCmp $3 'FDE' 0 error
			goto option

			mask:
			StrCmp $R9 'M=' 0 size
			StrCpy $4 $8
			goto option

			size:
			StrCmp $R9 'S=' 0 gotosubdir
			StrCpy $6 $8
			goto option

			gotosubdir:
			StrCmp $R9 'G=' 0 error
			StrCpy $7 $8
			StrCmp $7 '' +3
			StrCmp $7 '1' +2
			StrCmp $7 '0' 0 error
			goto option

			sizeset:
			StrCmp $6 '' default
			StrCpy $9 0
			StrCpy $R9 $6 1 $9
			StrCmp $R9 '' +4
			StrCmp $R9 ':' +3
			IntOp $9 $9 + 1
			goto -4
			StrCpy $5 $6 $9
			IntOp $9 $9 + 1
			StrCpy $1 $6 1 -1
			StrCpy $6 $6 -1 $9
			StrCmp $5 '' +2
			IntOp $5 $5 + 0
			StrCmp $6 '' +2
			IntOp $6 $6 + 0

			StrCmp $1 'B' 0 +3
			StrCpy $1 1
			goto default
			StrCmp $1 'K' 0 +3
			StrCpy $1 1024
			goto default
			StrCmp $1 'M' 0 +3
			StrCpy $1 1048576
			goto default
			StrCmp $1 'G' 0 error
			StrCpy $1 1073741824

			default:
			StrCmp $3 '' 0 +2
			StrCpy $3 'FD'
			StrCmp $4 '' 0 +2
			StrCpy $4 '*.*'
			StrCmp $7 '' 0 +2
			StrCpy $7 '1'

			StrCpy $8 1
			Push $0
			SetDetailsPrint textonly

			nextdir:
			IntOp $8 $8 - 1
			Pop $R8
			DetailPrint 'Search in: $R8'
			FindFirst $0 $R7 '$R8\$4'
			IfErrors subdir
			StrCmp $R7 '.' 0 +5
			FindNext $0 $R7
			StrCmp $R7 '..' 0 +3
			FindNext $0 $R7
			IfErrors subdir

			dir:
			IfFileExists '$R8\$R7\*.*' 0 file
			StrCpy $R6 ''
			StrCmp $3 'DE' +4
			StrCmp $3 'FDE' +3
			StrCmp $3 'FD' call
			StrCmp $3 'F' findnext call
			FindFirst $9 $R9 '$R8\$R7\*.*'
			StrCmp $R9 '.' 0 +4
			FindNext $9 $R9
			StrCmp $R9 '..' 0 +2
			FindNext $9 $R9
			FindClose $9
			IfErrors call findnext

			file:
			StrCmp $3 'FDE' +3
			StrCmp $3 'FD' +2
			StrCmp $3 'F' 0 findnext
			StrCpy $R6 0
			StrCmp $5$6 '' call
			FileOpen $9 '$R8\$R7' r
			IfErrors +3
			FileSeek $9 0 END $R6
			FileClose $9
			System::Int64Op $R6 / $1
			Pop $R6
			StrCmp $5 '' +2
			IntCmp $R6 $5 0 findnext
			StrCmp $6 '' +2
			IntCmp $R6 $6 0 0 findnext

			call:
			StrCpy $R9 '$R8\$R7'
			Push $0
			Push $1
			Push $2
			Push $3
			Push $4
			Push $5
			Push $6
			Push $7
			Push $8
			Push $R7
			Push $R8
			Call $2
			Pop $R9
			Pop $R8
			Pop $R7
			Pop $8
			Pop $7
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
			Pop $0
			IfErrors error

			StrCmp $R9 StopLocate +3 +4
			IntOp $8 $8 - 1
			Pop $R8
			StrCmp $8 0 end -2

			findnext:
			FindNext $0 $R7
			IfErrors 0 dir
			FindClose $0

			subdir:
			StrCmp $7 0 end
			FindFirst $0 $R7 '$R8\*.*'
			StrCmp $R7 '.' 0 +5
			FindNext $0 $R7
			StrCmp $R7 '..' 0 +3
			FindNext $0 $R7
			IfErrors +7

			IfFileExists '$R8\$R7\*.*' 0 +3
			Push '$R8\$R7'
			IntOp $8 $8 + 1
			FindNext $0 $R7
			IfErrors 0 -4
			FindClose $0
			StrCmp $8 0 end nextdir

			error:
			SetErrors

			end:
			SetDetailsPrint both
			Pop $R9
			Pop $R8
			Pop $R7
			Pop $R6
			Pop $9
			Pop $8
			Pop $7
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
			Pop $0
		FunctionEnd

		!undef _UNFILE
		!define _UNFILE
	!endif
!macroend

!macro GetSize
	!ifndef ${_UNFILE}GetSize
		!define ${_UNFILE}GetSize `!insertmacro ${_UNFILE}GetSizeCall`

		Function ${_UNFILE}GetSize
			Exch $1
			Exch
			Exch $0
			Exch
			Push $2
			Push $3
			Push $4
			Push $5
			Push $6
			Push $7
			Push $8
			Push $9
			Push $R3
			Push $R4
			Push $R5
			Push $R6
			Push $R7
			Push $R8
			Push $R9
			ClearErrors

			StrCpy $R9 $0 '' -1
			StrCmp $R9 '\' 0 +3
			StrCpy $0 $0 -1
			goto -3
			IfFileExists '$0\*.*' 0 error

			StrCpy $3 ''
			StrCpy $4 ''
			StrCpy $5 ''
			StrCpy $6 ''
			StrCpy $8 0
			StrCpy $R3 ''
			StrCpy $R4 ''
			StrCpy $R5 ''

			option:
			StrCpy $R9 $1 1
			StrCpy $1 $1 '' 1
			StrCmp $R9 ' ' -2
			StrCmp $R9 '' sizeset
			StrCmp $R9 '/' 0 -4

			StrCpy $9 0
			StrCpy $R9 $1 1 $9
			StrCmp $R9 '' +4
			StrCmp $R9 '/' +3
			IntOp $9 $9 + 1
			goto -4
			StrCpy $8 $1 $9
			StrCpy $8 $8 '' 2
			StrCpy $R9 $8 '' -1
			StrCmp $R9 ' ' 0 +3
			StrCpy $8 $8 -1
			goto -3
			StrCpy $R9 $1 2
			StrCpy $1 $1 '' $9

			StrCmp $R9 'M=' 0 size
			StrCpy $4 $8
			goto option

			size:
			StrCmp $R9 'S=' 0 gotosubdir
			StrCpy $6 $8
			goto option

			gotosubdir:
			StrCmp $R9 'G=' 0 error
			StrCpy $7 $8
			StrCmp $7 '' +3
			StrCmp $7 '1' +2
			StrCmp $7 '0' 0 error
			goto option

			sizeset:
			StrCmp $6 '' default
			StrCpy $9 0
			StrCpy $R9 $6 1 $9
			StrCmp $R9 '' +4
			StrCmp $R9 ':' +3
			IntOp $9 $9 + 1
			goto -4
			StrCpy $5 $6 $9
			IntOp $9 $9 + 1
			StrCpy $1 $6 1 -1
			StrCpy $6 $6 -1 $9
			StrCmp $5 '' +2
			IntOp $5 $5 + 0
			StrCmp $6 '' +2
			IntOp $6 $6 + 0

			StrCmp $1 'B' 0 +4
			StrCpy $1 1
			StrCpy $2 bytes
			goto default
			StrCmp $1 'K' 0 +4
			StrCpy $1 1024
			StrCpy $2 Kb
			goto default
			StrCmp $1 'M' 0 +4
			StrCpy $1 1048576
			StrCpy $2 Mb
			goto default
			StrCmp $1 'G' 0 error
			StrCpy $1 1073741824
			StrCpy $2 Gb

			default:
			StrCmp $4 '' 0 +2
			StrCpy $4 '*.*'
			StrCmp $7 '' 0 +2
			StrCpy $7 '1'

			StrCpy $8 1
			Push $0
			SetDetailsPrint textonly

			nextdir:
			IntOp $8 $8 - 1
			Pop $R8
			FindFirst $0 $R7 '$R8\$4'
			IfErrors show
			StrCmp $R7 '.' 0 +5
			FindNext $0 $R7
			StrCmp $R7 '..' 0 +3
			FindNext $0 $R7
			IfErrors show

			dir:
			IfFileExists '$R8\$R7\*.*' 0 file
			IntOp $R5 $R5 + 1
			goto findnext

			file:
			StrCpy $R6 0
			StrCmp $5$6 '' 0 +3
			IntOp $R4 $R4 + 1
			goto findnext
			FileOpen $9 '$R8\$R7' r
			IfErrors +3
			FileSeek $9 0 END $R6
			FileClose $9
			StrCmp $5 '' +2
			IntCmp $R6 $5 0 findnext
			StrCmp $6 '' +2
			IntCmp $R6 $6 0 0 findnext
			IntOp $R4 $R4 + 1
			System::Int64Op $R3 + $R6
			Pop $R3

			findnext:
			FindNext $0 $R7
			IfErrors 0 dir
			FindClose $0

			show:
			StrCmp $5$6 '' nosize
			System::Int64Op $R3 / $1
			Pop $9
			DetailPrint 'Size:$9 $2  Files:$R4  Folders:$R5'
			goto subdir
			nosize:
			DetailPrint 'Files:$R4  Folders:$R5'

			subdir:
			StrCmp $7 0 preend
			FindFirst $0 $R7 '$R8\*.*'
			StrCmp $R7 '.' 0 +5
			FindNext $0 $R7
			StrCmp $R7 '..' 0 +3
			FindNext $0 $R7
			IfErrors +7

			IfFileExists '$R8\$R7\*.*' 0 +3
			Push '$R8\$R7'
			IntOp $8 $8 + 1
			FindNext $0 $R7
			IfErrors 0 -4
			FindClose $0
			StrCmp $8 0 0 nextdir

			preend:
			StrCmp $R3 '' nosizeend
			System::Int64Op $R3 / $1
			Pop $R3
			nosizeend:
			StrCpy $2 $R4
			StrCpy $1 $R5
			StrCpy $0 $R3
			goto end

			error:
			SetErrors
			StrCpy $0 ''
			StrCpy $1 ''
			StrCpy $2 ''

			end:
			SetDetailsPrint both
			Pop $R9
			Pop $R8
			Pop $R7
			Pop $R6
			Pop $R5
			Pop $R4
			Pop $R3
			Pop $9
			Pop $8
			Pop $7
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Exch $2
			Exch
			Exch $1
			Exch 2
			Exch $0
		FunctionEnd

		!undef _UNFILE
		!define _UNFILE
	!endif
!macroend

!macro GetDrives
	!ifndef ${_UNFILE}GetDrives
		!define ${_UNFILE}GetDrives `!insertmacro ${_UNFILE}GetDrivesCall`

		Function ${_UNFILE}GetDrives
			Exch $1
			Exch
			Exch $0
			Exch
			Push $2
			Push $3
			Push $4
			Push $5
			Push $8
			Push $9

			System::Alloc 1024
			Pop $2

			StrCmp $0 '' 0 typeset
			StrCpy $0 ALL
			goto drivestring

			typeset:
			StrCpy $5 -1
			IntOp $5 $5 + 1
			StrCpy $8 $0 1 $5
			StrCmp $8$0 '' enumex
			StrCmp $8 '' +2
			StrCmp $8 '+' 0 -4
			StrCpy $8 $0 $5
			IntOp $5 $5 + 1
			StrCpy $0 $0 '' $5

			StrCmp $8 'FDD' 0 +3
			StrCpy $5 2
			goto drivestring
			StrCmp $8 'HDD' 0 +3
			StrCpy $5 3
			goto drivestring
			StrCmp $8 'NET' 0 +3
			StrCpy $5 4
			goto drivestring
			StrCmp $8 'CDROM' 0 +3
			StrCpy $5 5
			goto drivestring
			StrCmp $8 'RAM' 0 typeset
			StrCpy $5 6

			drivestring:
			System::Call 'kernel32::GetLogicalDriveStringsA(i,i) i(1024,r2)'

			enumok:
			System::Call 'kernel32::lstrlenA(t) i(i r2) .r3'
			StrCmp $3$0 '0ALL' enumex
			StrCmp $3 0 typeset
			System::Call 'kernel32::GetDriveTypeA(t) i (i r2) .r4'

			StrCmp $0 ALL +2
			StrCmp $4 $5 letter enumnext
			StrCmp $4 2 0 +3
			StrCpy $8 FDD
			goto letter
			StrCmp $4 3 0 +3
			StrCpy $8 HDD
			goto letter
			StrCmp $4 4 0 +3
			StrCpy $8 NET
			goto letter
			StrCmp $4 5 0 +3
			StrCpy $8 CDROM
			goto letter
			StrCmp $4 6 0 enumex
			StrCpy $8 RAM

			letter:
			System::Call '*$2(&t1024 .r9)'

			Push $0
			Push $1
			Push $2
			Push $3
			Push $4
			Push $5
			Push $8
			Call $1
			Pop $9
			Pop $8
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
			Pop $0
			StrCmp $9 'Stop' enumex

			enumnext:
			IntOp $2 $2 + $3
			IntOp $2 $2 + 1
			goto enumok

			enumex:
			System::Free $2

			Pop $9
			Pop $8
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
			Pop $0
		FunctionEnd

		!undef _UNFILE
		!define _UNFILE
	!endif
!macroend

!macro GetTime
	!ifndef ${_UNFILE}GetTime
		!define ${_UNFILE}GetTime `!insertmacro ${_UNFILE}GetTimeCall`

		Function ${_UNFILE}GetTime
			Exch $1
			Exch
			Exch $0
			Exch
			Push $2
			Push $3
			Push $4
			Push $5
			Push $6
			ClearErrors

			StrCmp $1 'L' gettime
			System::Call '*(i,l,l,l,i,i,i,i,&t260,&t14) i .r2'
			System::Call 'kernel32::FindFirstFileA(t,i)i(r0,r2) .r3'
			IntCmp $3 -1 error
			System::Call 'kernel32::FindClose(i)i(r3)'

			gettime:
			System::Call '*(&i2,&i2,&i2,&i2,&i2,&i2,&i2,&i2) i .r0'
			StrCmp $1 'L' 0 filetime
			System::Call 'kernel32::GetLocalTime(i)i(r0)'
			goto convert

			filetime:
			System::Call '*$2(i,l,l,l,i,i,i,i,&t260,&t14)i(,.r6,.r5,.r4)'
			StrCmp $1 'A' 0 +3
			StrCpy $4 $5
			goto +5
			StrCmp $1 'C' 0 +3
			StrCpy $4 $6
			goto +2
			StrCmp $1 'M' 0 error
			System::Call 'kernel32::FileTimeToLocalFileTime(*l,*l)i(r4,.r3)'
			System::Call 'kernel32::FileTimeToSystemTime(*l,i)i(r3,r0)'
			System::Free $2

			convert:
			System::Call '*$0(&i2,&i2,&i2,&i2,&i2,&i2,&i2,&i2)i(.r5,.r6,.r4,.r0,.r3,.r2,.r1,)'

			IntCmp $1 9 0 0 +2
			StrCpy $1 '0$1'
			IntCmp $2 9 0 0 +2
			StrCpy $2 '0$2'

			StrCmp $4 0 0 +3
			StrCpy $4 Sunday
			goto end
			StrCmp $4 1 0 +3
			StrCpy $4 Monday
			goto end
			StrCmp $4 2 0 +3
			StrCpy $4 Tuesday
			goto end
			StrCmp $4 3 0 +3
			StrCpy $4 Wednesday
			goto end
			StrCmp $4 4 0 +3
			StrCpy $4 Thursday
			goto end
			StrCmp $4 5 0 +3
			StrCpy $4 Friday
			goto end
			StrCmp $4 6 0 error
			StrCpy $4 Saturday
			goto end

			error:
			System::Free $2
			StrCpy $0 ''
			StrCpy $1 ''
			StrCpy $2 ''
			StrCpy $3 ''
			StrCpy $4 ''
			StrCpy $5 ''
			StrCpy $6 ''
			SetErrors

			end:
			Exch $6
			Exch
			Exch $5
			Exch 2
			Exch $4
			Exch 3
			Exch $3
			Exch 4
			Exch $2
			Exch 5
			Exch $1
			Exch 6
			Exch $0
		FunctionEnd

		!undef _UNFILE
		!define _UNFILE
	!endif
!macroend

!macro GetExeName
	!ifndef ${_UNFILE}GetExeName
		!define ${_UNFILE}GetExeName `!insertmacro ${_UNFILE}GetExeNameCall`

		Function ${_UNFILE}GetExeName
			Push $0
			Push $1

			StrCpy $1 $CMDLINE 1
			StrCmp $1 '"' 0 kernel
			StrCpy $1 0
			IntOp $1 $1 + 1
			StrCpy $0 $CMDLINE 1 $1
			StrCmp $0 '"' 0 -2
			IntOp $1 $1 - 1
			StrCpy $0 $CMDLINE $1 1
			goto end

			kernel:
			System::Call 'kernel32::GetModuleFileNameA(i 0, t .r0, i 1024) i r1'

			end:
			Pop $1
			Exch $0
		FunctionEnd

		!undef _UNFILE
		!define _UNFILE
	!endif
!macroend


!macro GetExePath
	!ifndef ${_UNFILE}GetExePath
		!define ${_UNFILE}GetExePath `!insertmacro ${_UNFILE}GetExePathCall`

		Function ${_UNFILE}GetExePath
			Push $0
			Push $1
			Push $2

			StrCpy $1 $CMDLINE 1
			StrCmp $1 '"' 0 exedir
			StrCpy $1 0
			IntOp $1 $1 + 1
			StrCpy $0 $CMDLINE 1 $1
			StrCmp $0 '"' 0 -2
			IntOp $1 $1 - 1
			StrCpy $0 $CMDLINE $1 1

			StrCpy $1 0
			IntOp $1 $1 - 1
			StrCpy $2 $0 1 $1
			StrCmp $2 '\' 0 -2
			StrCpy $0 $0 $1
			goto end

			exedir:
			StrCpy $0 $EXEDIR

			end:
			Pop $2
			Pop $1
			Exch $0
		FunctionEnd

		!undef _UNFILE
		!define _UNFILE
	!endif
!macroend

!macro GetParameters
	!ifndef ${_UNFILE}GetParameters
		!define ${_UNFILE}GetParameters `!insertmacro ${_UNFILE}GetParametersCall`

		Function ${_UNFILE}GetParameters
			Push $0
			Push $1
			Push $2

			StrCpy $1 1
			StrCpy $0 $CMDLINE 1
			StrCmp $0 '"' 0 +3
			StrCpy $2 '"'
			goto +2
			StrCpy $2 ' '

			IntOp $1 $1 + 1
			StrCpy $0 $CMDLINE 1 $1
			StrCmp $0 $2 +2
			StrCmp $0 '' end -3

			IntOp $1 $1 + 1
			StrCpy $0 $CMDLINE 1 $1
			StrCmp $0 ' ' -2
			StrCpy $0 $CMDLINE '' $1

			StrCpy $1 $0 1 -1
			StrCmp $1 ' ' 0 +3
			StrCpy $0 $0 -1
			goto -3

			end:
			Pop $2
			Pop $1
			Exch $0
		FunctionEnd

		!undef _UNFILE
		!define _UNFILE
	!endif
!macroend

!macro GetBaseName
	!ifndef ${_UNFILE}GetBaseName
		!define ${_UNFILE}GetBaseName `!insertmacro ${_UNFILE}GetBaseNameCall`

		Function ${_UNFILE}GetBaseName
			Exch $0
			Push $1
			Push $2
			Push $3

			StrCpy $1 0
			StrCpy $3 ''

			loop:
			IntOp $1 $1 - 1
			StrCpy $2 $0 1 $1
			StrCmp $2 '' trimpath
			StrCmp $2 '\' trimpath
			StrCmp $3 'noext' loop
			StrCmp $2 '.' 0 loop
			StrCpy $0 $0 $1
			StrCpy $3 'noext'
			StrCpy $1 0
			goto loop

			trimpath:
			IntOp $1 $1 + 1
			StrCpy $0 $0 '' $1

			Pop $3
			Pop $2
			Pop $1
			Exch $0
		FunctionEnd

		!undef _UNFILE
		!define _UNFILE
	!endif
!macroend

!macro GetFileExt
	!ifndef ${_UNFILE}GetFileExt
		!define ${_UNFILE}GetFileExt `!insertmacro ${_UNFILE}GetFileExtCall`

		Function ${_UNFILE}GetFileExt
			Exch $0
			Push $1
			Push $2

			StrCpy $1 0

			loop:
			IntOp $1 $1 - 1
			StrCpy $2 $0 1 $1
			StrCmp $2 '' empty
			StrCmp $2 '\' empty
			StrCmp $2 '.' found
			goto loop

			found:
			IntOp $1 $1 + 1
			StrCpy $0 $0 '' $1
			goto exit

			empty:
			StrCpy $0 ''

			exit:
			Pop $2
			Pop $1
			Exch $0
		FunctionEnd

		!undef _UNFILE
		!define _UNFILE
	!endif
!macroend

!macro GetFileVersion
	!ifndef ${_UNFILE}GetFileVersion
		!define ${_UNFILE}GetFileVersion `!insertmacro ${_UNFILE}GetFileVersionCall`

		Function ${_UNFILE}GetFileVersion
			Exch $0
			Push $1
			Push $2
			Push $3
			Push $4
			Push $5
			Push $6

			GetDllVersion '$0' $1 $2
			IfErrors error
			IntOp $3 $1 / 0x00010000
			IntOp $4 $1 & 0x0000FFFF
			IntOp $5 $2 / 0x00010000
			IntOp $6 $2 & 0x0000FFFF
			StrCpy $0 '$3.$4.$5.$6'
			goto end

			error:
			SetErrors
			StrCpy $0 ''

			end:
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
			Exch $0
		FunctionEnd

		!undef _UNFILE
		!define _UNFILE
	!endif
!macroend

!macro VersionCompare
	!ifndef ${_UNFILE}VersionCompare
		!define ${_UNFILE}VersionCompare `!insertmacro ${_UNFILE}VersionCompareCall`

		Function ${_UNFILE}VersionCompare
			Exch $1
			Exch
			Exch $0
			Exch
			Push $2
			Push $3
			Push $4
			Push $5
			Push $6
			Push $7

			begin:
			StrCpy $2 -1
			IntOp $2 $2 + 1
			StrCpy $3 $0 1 $2
			StrCmp $3 '' +2
			StrCmp $3 '.' 0 -3
			StrCpy $4 $0 $2
			IntOp $2 $2 + 1
			StrCpy $0 $0 '' $2

			StrCpy $2 -1
			IntOp $2 $2 + 1
			StrCpy $3 $1 1 $2
			StrCmp $3 '' +2
			StrCmp $3 '.' 0 -3
			StrCpy $5 $1 $2
			IntOp $2 $2 + 1
			StrCpy $1 $1 '' $2

			StrCmp $4$5 '' equal

			StrCpy $6 -1
			IntOp $6 $6 + 1
			StrCpy $3 $4 1 $6
			StrCmp $3 '0' -2
			StrCmp $3 '' 0 +2
			StrCpy $4 0

			StrCpy $7 -1
			IntOp $7 $7 + 1
			StrCpy $3 $5 1 $7
			StrCmp $3 '0' -2
			StrCmp $3 '' 0 +2
			StrCpy $5 0

			StrCmp $4 0 0 +2
			StrCmp $5 0 begin newer2
			StrCmp $5 0 newer1
			IntCmp $6 $7 0 newer1 newer2

			StrCpy $4 '1$4'
			StrCpy $5 '1$5'
			IntCmp $4 $5 begin newer2 newer1

			equal:
			StrCpy $0 0
			goto end
			newer1:
			StrCpy $0 1
			goto end
			newer2:
			StrCpy $0 2

			end:
			Pop $7
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
			Exch $0
		FunctionEnd

		!undef _UNFILE
		!define _UNFILE
	!endif
!macroend

!macro DirState
	!ifndef ${_UNFILE}DirState
		!define ${_UNFILE}DirState `!insertmacro ${_UNFILE}DirStateCall`

		Function ${_UNFILE}DirState
			Exch $0
			Push $1

			FindFirst $1 $0 '$0\*.*'
			IfErrors 0 +3
			StrCpy $0 -1
			goto end
			StrCmp $0 '.' 0 +4
			FindNext $1 $0
			StrCmp $0 '..' 0 +2
			FindNext $1 $0
			FindClose $1
			IfErrors 0 +3
			StrCpy $0 0
			goto end
			StrCpy $0 1

			end:
			Pop $1
			Exch $0
		FunctionEnd

		!undef _UNFILE
		!define _UNFILE
	!endif
!macroend

!macro RefreshShellIcons
	!ifndef ${_UNFILE}RefreshShellIcons
		!define ${_UNFILE}RefreshShellIcons `!insertmacro ${_UNFILE}RefreshShellIconsCall`

		Function ${_UNFILE}RefreshShellIcons
			System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'
		FunctionEnd

		!undef _UNFILE
		!define _UNFILE
	!endif
!macroend

!macro un.LocateCall _PATH _OPTIONS _FUNC
	Push $0
	Push `${_PATH}`
	Push `${_OPTIONS}`
	GetFunctionAddress $0 `${_FUNC}`
	Push `$0`
	Call un.Locate
	Pop $0
!macroend

!macro un.GetSizeCall _PATH _OPTION _RESULT1 _RESULT2 _RESULT3
	Push `${_PATH}`
	Push `${_OPTION}`
	Call un.GetSize
	Pop ${_RESULT1}
	Pop ${_RESULT2}
	Pop ${_RESULT3}
!macroend

!macro un.GetDrivesCall _DRV _FUNC
	Push $0
	Push `${_DRV}`
	GetFunctionAddress $0 `${_FUNC}`
	Push `$0`
	Call un.GetDrives
	Pop $0
!macroend

!macro un.GetTimeCall _FILE _OPTION _RESULT1 _RESULT2 _RESULT3 _RESULT4 _RESULT5 _RESULT6 _RESULT7
	Push `${_FILE}`
	Push `${_OPTION}`
	Call un.GetTime
	Pop ${_RESULT1}
	Pop ${_RESULT2}
	Pop ${_RESULT3}
	Pop ${_RESULT4}
	Pop ${_RESULT5}
	Pop ${_RESULT6}
	Pop ${_RESULT7}
!macroend

!macro un.GetExeNameCall _RESULT
	Call un.GetExeName
	Pop ${_RESULT}
!macroend

!macro un.GetExePathCall _RESULT
	Call un.GetExePath
	Pop ${_RESULT}
!macroend

!macro un.GetParametersCall _RESULT
	Call un.GetParameters
	Pop ${_RESULT}
!macroend

!macro un.GetBaseNameCall _FILESTRING _RESULT
	Push `${_FILESTRING}`
	Call un.GetBaseName
	Pop ${_RESULT}
!macroend


!macro un.GetFileExtCall _FILESTRING _RESULT
	Push `${_FILESTRING}`
	Call un.GetFileExt
	Pop ${_RESULT}
!macroend

!macro un.GetFileVersionCall _FILE _RESULT
	Push `${_FILE}`
	Call un.GetFileVersion
	Pop ${_RESULT}
!macroend

!macro un.VersionCompareCall _VER1 _VER2 _RESULT
	Push `${_VER1}`
	Push `${_VER2}`
	Call un.VersionCompare
	Pop ${_RESULT}
!macroend

!macro un.DirStateCall _PATH _RESULT
	Push `${_PATH}`
	Call un.DirState
	Pop ${_RESULT}
!macroend

!macro un.RefreshShellIconsCall
	Call RefreshShellIcons
!macroend

!macro un.Locate
	!ifndef un.Locate
		!undef _UNFILE
		!define _UNFILE `un.`

		!insertmacro Locate
	!endif
!macroend

!macro un.GetSize
	!ifndef un.GetSize
		!undef _UNFILE
		!define _UNFILE `un.`

		!insertmacro GetSize
	!endif
!macroend

!macro un.GetDrives
	!ifndef un.GetDrives
		!undef _UNFILE
		!define _UNFILE `un.`

		!insertmacro GetDrives
	!endif
!macroend

!macro un.GetTime
	!ifndef un.GetTime
		!undef _UNFILE
		!define _UNFILE `un.`

		!insertmacro GetTime
	!endif
!macroend

!macro un.GetExeName
	!ifndef un.GetExeName
		!undef _UNFILE
		!define _UNFILE `un.`

		!insertmacro GetExeName
	!endif
!macroend

!macro un.GetExePath
	!ifndef un.GetExePath
		!undef _UNFILE
		!define _UNFILE `un.`

		!insertmacro GetExePath
	!endif
!macroend

!macro un.GetParameters
	!ifndef un.GetParameters
		!undef _UNFILE
		!define _UNFILE `un.`

		!insertmacro GetParameters
	!endif
!macroend

!macro un.GetBaseName
	!ifndef un.GetBaseName
		!undef _UNFILE
		!define _UNFILE `un.`

		!insertmacro GetBaseName
	!endif
!macroend

!macro un.GetFileExt
	!ifndef un.GetFileExt
		!undef _UNFILE
		!define _UNFILE `un.`

		!insertmacro GetFileExt
	!endif
!macroend

!macro un.GetFileVersion
	!ifndef un.GetFileVersion
		!undef _UNFILE
		!define _UNFILE `un.`

		!insertmacro GetFileVersion
	!endif
!macroend

!macro un.VersionCompare
	!ifndef un.VersionCompare
		!undef _UNFILE
		!define _UNFILE `un.`

		!insertmacro VersionCompare
	!endif
!macroend

!macro un.DirState
	!ifndef un.DirState
		!undef _UNFILE
		!define _UNFILE `un.`

		!insertmacro DirState
	!endif
!macroend

!macro un.RefreshShellIcons
	!ifndef un.RefreshShellIcons
		!undef _UNFILE
		!define _UNFILE `un.`

		!insertmacro RefreshShellIcons
	!endif
!macroend
