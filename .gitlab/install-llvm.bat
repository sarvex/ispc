call %SCRIPTS_DIR%\download-file.bat %ARTIFACTORY_ISPC_URL%/llvm latest.%LLVM_VER% %ARTIFACTORY_ISPC_API_KEY% || goto :error
set /p LATEST_LLVM=<latest.%LLVM_VER%

IF NOT EXIST %LLVM_HOME%\%LLVM_VER% GOTO :get_llvm
set /p CURRENT_LLVM=<%LLVM_HOME%\%LLVM_VER%\latest.%LLVM_VER%
if "%LATEST_LLVM%" == "%CURRENT_LLVM%" GOTO :EOF

:get_llvm
call %SCRIPTS_DIR%\download-file.bat %ARTIFACTORY_ISPC_URL%/llvm/%LATEST_LLVM% llvm-%LLVM_VER%.zip %ARTIFACTORY_ISPC_API_KEY% || goto :error
unzip -o -q llvm-%LLVM_VER%.zip
del /F /Q llvm-%LLVM_VER%.zip
copy latest.%LLVM_VER% %LLVM_VER%\
rd /s /q %LLVM_HOME%\%LLVM_VER%
move %LLVM_VER% %LLVM_HOME%\

goto :EOF

:error
echo Failed - error #%errorlevel%
exit /b %errorlevel%
