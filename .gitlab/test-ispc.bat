set TESTS_TARGET=%1
set ISPC_OUTPUT=%2
set FAIL_DB_PATH=%3
set ARTIFACTORY_BASE_URL=%4
set CPU_TARGET=%5

IF not "%CPU_TARGET%"=="" (
  set EXTRA_ARGS=--device=%CPU_TARGET%
)

call %SCRIPTS_DIR%\install-gfx-driver.bat %ARTIFACTORY_BASE_URL% || goto :error

cd %CI_PROJECT_DIR%
call %SCRIPTS_DIR%\download-file.bat %ARTIFACTORY_BASE_URL% level-zero.zip %ARTIFACTORY_ISPC_API_KEY% || goto :error
unzip level-zero.zip || goto :error
set PATH=%CI_PROJECT_DIR%\build\install\bin;%PATH%

python run_tests.py -u FP -a xe64 -t %TESTS_TARGET% --l0loader=%CI_PROJECT_DIR%\level-zero --ispc_output=%ISPC_OUTPUT% --fail_db=%FAIL_DB_PATH% --test_time 20 %EXTRA_ARGS% || goto :error

:check_exising_processes
rem check for any still running processes
tasklist | grep ispc || goto :EOF
timeout /T 10
goto :check_exising_processes

goto :EOF

:error
echo Failed - error #%errorlevel%
exit /b %errorlevel%
