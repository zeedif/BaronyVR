@echo off
rem Dev build of BaronyVR (Steamworks + FMOD, no EOS) against local deps.
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat" >nul || exit /b 1
set DEPS=D:\Workspace\BaronyVR-deps
set STEAMWORKS_ROOT=%DEPS%\steamworks
set FMOD_DIR=%DEPS%\fmod
set NFD_DIR=%DEPS%\nfd
set STEAMWORKS_ENABLED=1
set EOS_ENABLED=0
set CMAKEBIN=C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin
set PATH=%CMAKEBIN%;C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;%PATH%
if not exist %DEPS%\build\build.ninja (
  cmake -S D:\Workspace\BaronyVR -B %DEPS%\build -G Ninja ^
    -DCMAKE_BUILD_TYPE=RelWithDebInfo ^
    -DCMAKE_TOOLCHAIN_FILE=%DEPS%\vcpkg\scripts\buildsystems\vcpkg.cmake ^
    -DVCPKG_TARGET_TRIPLET=x64-windows ^
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DFMOD_ENABLED=ON -DOPENAL_ENABLED=OFF -DEDITOR=OFF || exit /b 1
)
cmake --build %DEPS%\build --target barony %*
