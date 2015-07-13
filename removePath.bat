@echo off
echo Removing Toolchain Paths...
echo. 
pathed -r "%~dp0Toolchain\Make\bin" -x
pathed -r "%~dp0Toolchain\GCC-ARM\bin" -x
pathed -r "%~dp0Toolchain\MinGW" -x
pathed -r "%~dp0Toolchain\MinGW\msys\1.0\bin" -x
pathed -p >nul
echo.
echo. 
echo New User Path:
pathed -l
echo. 