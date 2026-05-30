# Flutter Android Emulator Setup Guide

## What's Been Done

✅ **Fixed Issues:**
1. Created missing `assets/images/` directory
2. Built the APK successfully (debug build)
3. Created Android Virtual Device (AVD) configuration for emulator
4. Registered emulator: `flutter_emulator`

## How to Run the App

### Option 1: Using the Run Script (Recommended)
1. Open Command Prompt (NOT PowerShell)
2. Navigate to: `d:\hris-mobileApp\flutter_app`
3. Double-click `run_emulator.bat` OR run:
   ```cmd
   run_emulator.bat
   ```

### Option 2: Manual Steps

**Step 1: Start the Emulator**
```cmd
cd C:\Users\User\AppData\Local\Android\sdk\emulator
emulator.exe -avd flutter_emulator -no-boot-anim
```

**Step 2: Wait for Boot** (approximately 30-60 seconds)

**Step 3: Run the App** (in a new command prompt)
```cmd
cd d:\hris-mobileApp\flutter_app
flutter run
```

## Troubleshooting

### If emulator doesn't start:
1. Ensure Android SDK is properly installed at: `C:\Users\User\AppData\Local\Android\sdk`
2. Check that system images are available by running:
   ```cmd
   dir "C:\Users\User\AppData\Local\Android\sdk\system-images"
   ```

### If `flutter run` says no devices found:
1. Check emulator is running: `adb devices`
2. Wait longer for emulator to fully boot (can take 1-2 minutes)
3. Restart the emulator if needed

### If build fails:
1. Clean build: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Try building again: `flutter run`

## App Information
- **Package Name:** com.example.hris_mobile
- **Min SDK:** Android 21+
- **Target SDK:** Latest (API 34+)
- **Architecture:** x86_64 (for emulator)

## What the App Does
- Displays list of employees
- Uses Riverpod for state management
- Uses Dio for API calls
- Secure storage for sensitive data
