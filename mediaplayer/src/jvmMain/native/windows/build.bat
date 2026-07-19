@echo off
setlocal

set "TARGET_ARCH=%~1"
if "%TARGET_ARCH%"=="" set "TARGET_ARCH=x64"
if /I not "%TARGET_ARCH%"=="x64" if /I not "%TARGET_ARCH%"=="ARM64" (
    echo Unsupported Windows architecture: %TARGET_ARCH%
    exit /b 1
)

set "BUILD_DIR=build-%TARGET_ARCH%"

echo === Starting compilation for %TARGET_ARCH% ===

rem Clean the current architecture's previous build directory
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"

rem Clear local DLL cache so the JVM loader picks up the new build
set "NATIVE_CACHE=%LOCALAPPDATA%\composemediaplayer\native"
if exist "%NATIVE_CACHE%" (
    echo Clearing native DLL cache: %NATIVE_CACHE%
    rmdir /s /q "%NATIVE_CACHE%"
)

echo.
echo === %TARGET_ARCH% Configuration ===
cmake -B "%BUILD_DIR%" -A "%TARGET_ARCH%" .
if %ERRORLEVEL% neq 0 (
    echo Error during %TARGET_ARCH% configuration
    exit /b %ERRORLEVEL%
)

echo.
echo === %TARGET_ARCH% Compilation ===
cmake --build "%BUILD_DIR%" --config Release
if %ERRORLEVEL% neq 0 (
    echo Error during %TARGET_ARCH% compilation
    exit /b %ERRORLEVEL%
)

echo.
echo === Compilation completed successfully for %TARGET_ARCH% ===
echo.

rem Clean up the current architecture's build directory
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"

if /I "%TARGET_ARCH%"=="ARM64" (
    echo DLL: ..\..\resources\composemediaplayer\native\win32-arm64\NativeVideoPlayer.dll
) else (
    echo DLL: ..\..\resources\composemediaplayer\native\win32-x86-64\NativeVideoPlayer.dll
)

endlocal
