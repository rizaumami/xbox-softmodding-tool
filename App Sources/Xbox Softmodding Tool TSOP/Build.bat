@Echo off & COLOR 1B & TITLE Xbox Softmodding Tool TSOP Batch
goto getadminwrites >NUL

:start
CD "%~dp0"

IF "%VS71COMNTOOLS%"=="" (
  SET NET="%ProgramFiles%\Microsoft Visual Studio .NET 2003\Common7\IDE\devenv.com"
) ELSE (
  SET NET="%VS71COMNTOOLS%\..\IDE\devenv.com"
)

IF NOT EXIST %NET% (
  CALL:ERROR "Visual Studio .NET 2003 was not found."
  GOTO:EOF
)

SET "XBE_PATCH=..\..\other\tools\xbepatch.exe"
SET "Habibi=..\..\other\tools\xbedump.exe"
SET XBE=default.xbe
SET DEST=Build
SET "DEST2=..\..\Extras Disc\FlashSM\Prep\stage2\"
RMDIR %DEST% /S /Q 2>NUL
MKDIR %DEST%

ECHO Wait while preparing the build.
ECHO ------------------------------------------------------------
ECHO %NET% "Xbox Softmod Tool Kit.sln" /build Release
%NET% "Xbox Softmod Tool Kit.sln" /build Release

copy "Release\%XBE%" "%DEST%\%XBE%"
rmdir /S /Q "Release"
echo:
if exist "%DEST%\%XBE%" (
ECHO - XBE Patching %DEST%\%XBE%
%XBE_PATCH% "%DEST%\%XBE%"
ECHO - Patching Done!
(
XCopy /s /y /e "Media" "%DEST%\" >NUL
RD /Q /S "%DEST%\PSD's" 2>NUL
%Habibi% "%DEST%\%XBE%" -habibi
del /q "%DEST%\%XBE%"
ren "out.xbe" "%XBE%"
echo "%XBE%" "%DEST2%"
move "%XBE%" "%DEST%"
XCopy /s /y /e "%DEST%" "%DEST2%" >NUL
)>NUL
ECHO - XBE Signing %DEST%\%XBE%
Echo - XBE Signed!
)
pause & goto start
timeout /t 10
exit

:getadminwrites
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)
REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
   goto start