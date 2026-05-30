@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Flutter Android Emulator Setup
echo ========================================

set SDK_PATH=C:\Users\User\AppData\Local\Android\sdk
set EMULATOR=%SDK_PATH%\emulator\emulator.exe
set ADB=%SDK_PATH%\platform-tools\adb.exe

REM Check if emulator exists
if not exist "%EMULATOR%" (
    echo ERROR: Emulator not found at %EMULATOR%
    echo Please ensure Android SDK is installed properly
    pause
    exit /b 1
)

REM Check for running emulator
echo Checking for running emulator...
"%ADB%" devices > nul 2>&1

REM Start emulator if not running
echo Starting Android emulator (flutter_emulator)...
start "" "%EMULATOR%" -avd flutter_emulator -no-boot-anim -wipe-data

REM Wait for emulator to boot
echo.
echo Waiting for emulator to fully boot...
echo (This may take 30-60 seconds)
timeout /t 15 /nobreak

REM Check device is ready
echo.
echo Verifying emulator is ready...
:check_ready
"%ADB%" devices | find "device" > nul
if %errorlevel% neq 0 (
    echo Still booting, waiting...
    timeout /t 5 /nobreak
    goto check_ready
)

REM Navigate to app directory
echo.
echo ========================================
echo Running Flutter app...
echo ========================================
cd /d d:\hris-mobileApp\flutter_app

REM Get dependencies
echo Ensuring dependencies are installed...
call flutter pub get

REM Run the app
call flutter run

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo App launched successfully!
    echo ========================================
) else (
    echo.
    echo ERROR: Flutter run failed with error code !errorlevel!
)

pause
endlocal
