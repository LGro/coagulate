@echo off
setlocal

REM #############################################

CALL ..\..\veilid\dev-setup\setup_windows.bat

PUSHD %~dp0\..
SET VEILIDCHATDIR=%CD%
POPD

IF NOT DEFINED ProgramFiles(x86) (
    echo This script requires a 64-bit Windows Installation. Exiting.
    goto end
)

FOR %%X IN (protoc.exe) DO (SET PROTOC_FOUND=%%~$PATH:X)
IF NOT DEFINED PROTOC_FOUND (
    echo protobuf compiler ^(protoc^) is required but it's not installed. Install protoc 23.2 or higher. Ensure it is in your path. Aborting.
    echo protoc is available here: https://github.com/protocolbuffers/protobuf/releases/download/v23.2/protoc-23.2-win64.zip
    goto end
)

echo Setup successful
:end
ENDLOCAL
