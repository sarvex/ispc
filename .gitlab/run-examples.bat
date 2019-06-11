set ARTIFACTORY_BASE_URL=%1
call %SCRIPTS_DIR%\install-gfx-driver.bat %ARTIFACTORY_BASE_URL% || goto :error

cd %CI_PROJECT_DIR%
call %SCRIPTS_DIR%\download-file.bat %ARTIFACTORY_BASE_URL% level-zero.zip %ARTIFACTORY_ISPC_API_KEY% || goto :error
unzip level-zero.zip || goto :error
set PATH=%CI_PROJECT_DIR%\build\install\bin;%PATH%

cd %CI_PROJECT_DIR%\examples\xpu && mkdir build && cd build
cmake -DLEVEL_ZERO_ROOT=%CI_PROJECT_DIR%\level-zero ../  || goto :error

REM Build ISPC examples
MSBuild XeExamples.sln /p:Configuration=Release /p:Platform=x64 /m || goto :error

REM Run examples
ctest -C Release -V --timeout 30 || goto :error

goto :EOF

:error
echo Failed - error #%errorlevel%
exit /b %errorlevel%
