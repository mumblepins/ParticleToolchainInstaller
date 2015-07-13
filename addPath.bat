@echo off
echo Adding Toolchain Paths...
echo. 
pathed -a "%~dp0Toolchain\Make\bin" -x
pathed -a "%~dp0Toolchain\GCC-ARM\bin" -x
pathed -a "%~dp0Toolchain\MinGW" -x
pathed -a "%~dp0Toolchain\MinGW\msys\1.0\bin" -x
pathed -p >nul
echo.
echo. 
echo New User Path:
pathed -l
echo.