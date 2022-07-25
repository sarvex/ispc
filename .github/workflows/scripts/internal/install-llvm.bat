call %SCRIPTS_DIR%\download-file.bat %ARTIFACTORY_ISPC_URL%/llvm latest.%LLVM_VER_WITH_SUFFIX% %ARTIFACTORY_ISPC_API_KEY% || goto :error
set /p LATEST_LLVM=<latest.%LLVM_VER_WITH_SUFFIX%

IF NOT EXIST %LLVM_HOME%\%LLVM_VER_WITH_SUFFIX% GOTO :get_llvm
set /p CURRENT_LLVM=<%LLVM_HOME%\%LLVM_VER_WITH_SUFFIX%\latest.%LLVM_VER_WITH_SUFFIX%
if "%LATEST_LLVM%" == "%CURRENT_LLVM%" GOTO :EOF

:get_llvm
call %SCRIPTS_DIR%\download-file.bat %ARTIFACTORY_ISPC_URL%/llvm/%LATEST_LLVM% llvm-%LLVM_VER_WITH_SUFFIX%.zip %ARTIFACTORY_ISPC_API_KEY% || goto :error
unzip -o -q llvm-%LLVM_VER_WITH_SUFFIX%.zip
del /F /Q llvm-%LLVM_VER_WITH_SUFFIX%.zip
copy latest.%LLVM_VER_WITH_SUFFIX% %LLVM_VER_WITH_SUFFIX%\
rd /s /q %LLVM_HOME%\%LLVM_VER_WITH_SUFFIX%
move %LLVM_VER_WITH_SUFFIX% %LLVM_HOME%\

goto :EOF

:error
echo Failed - error #%errorlevel%
exit /b %errorlevel%
