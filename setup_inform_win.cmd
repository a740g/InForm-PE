@rem InForm for QB64-PE Setup script
@echo off

rem Check if QB64-PE directory path is provided as an argument
if "%~1" neq "" (
    set "QB64PE_PATH=%~1"
) else (
    set "QB64PE_PATH=..\QB64pe"
)

cd /d "%~dp0"

echo Compiling InForm-PE release. Please be patient...

rem Attempt build with QB64-PE path
%QB64PE_PATH%\internal\c\c_compiler\bin\mingw32-make.exe -f inform.mk clean OS=Windows_NT QB64PE_PATH=%QB64PE_PATH%
%QB64PE_PATH%\internal\c\c_compiler\bin\mingw32-make.exe -f inform.mk release OS=Windows_NT QB64PE_PATH=%QB64PE_PATH%
if not errorlevel 1 exit /b

echo Build failed with QB64-PE path: %QB64PE_PATH%
echo Retrying with alternative QB64-PE directory...

rem Retry build with ..\QB64pe as fallback if it exists

set "QB64PE_PATH=..\QB64pe"

if exist %QB64PE_PATH% (
    %QB64PE_PATH%\internal\c\c_compiler\bin\mingw32-make.exe -f inform.mk clean OS=Windows_NT QB64PE_PATH=%QB64PE_PATH%
    %QB64PE_PATH%\internal\c\c_compiler\bin\mingw32-make.exe -f inform.mk release OS=Windows_NT QB64PE_PATH=%QB64PE_PATH%
)
