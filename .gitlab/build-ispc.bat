set BUILD_EMBARGO=%1
set ARTIFACTORY_BASE_URL=%2
set LLVM_HOME=C:\llvm
set LLVM_VER=13.0
call %SCRIPTS_DIR%\install-llvm.bat || goto :error

set ARTIFACTORY_GFX_BASE_URL=%ARTIFACTORY_ISPC_URL%/ispc-deps

cd %CI_PROJECT_DIR%
call %SCRIPTS_DIR%\download-file.bat %ARTIFACTORY_BASE_URL% vc-intrinsics.zip %ARTIFACTORY_ISPC_API_KEY% || goto :error
call %SCRIPTS_DIR%\download-file.bat %ARTIFACTORY_BASE_URL% spirv-translator.zip %ARTIFACTORY_ISPC_API_KEY% || goto :error
call %SCRIPTS_DIR%\download-file.bat %ARTIFACTORY_BASE_URL% level-zero.zip %ARTIFACTORY_ISPC_API_KEY% || goto :error
mkdir deps
unzip vc-intrinsics.zip && cp -rf vc-intrinsics/* deps/ || goto :error
unzip spirv-translator.zip && cp -rf spirv-translator/* deps/ || goto :error
unzip level-zero.zip || goto :error

mkdir build
cd build
cmake -DISPC_INCLUDE_TESTS=ON -DXE_ENABLED=ON -DISPC_INCLUDE_BENCHMARKS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=install -D__INTEL_EMBARGO__=%BUILD_EMBARGO% -DLLVM_DIR=%LLVM_HOME%\%LLVM_VER%\bin-%LLVM_VER%\lib\cmake\llvm -DXE_DEPS_DIR=%CI_PROJECT_DIR%\deps -DLEVEL_ZERO_ROOT=%CI_PROJECT_DIR%\level-zero ../ || goto :error

REM Build ISPC
MSBuild ispc.sln /p:Configuration=Release /p:Platform=x64 /m || goto :error

REM Run lit tests
cmake --build . --target check-all --config Release || goto :error

REM Install ISPC
cmake --build . --target INSTALL --config Release || goto :error

goto :EOF

:error
echo Failed - error #%errorlevel%
exit /b %errorlevel%
