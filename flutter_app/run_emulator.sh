#!/bin/bash
# Quick launcher script for macOS/Linux users

set -e

echo "=========================================="
echo "Flutter Android Emulator Launcher"
echo "=========================================="

SDK_PATH="$HOME/Library/Android/sdk"
if [[ ! -d "$SDK_PATH" ]]; then
    SDK_PATH="$HOME/AppData/Local/Android/sdk"  # Windows
fi

EMULATOR="$SDK_PATH/emulator/emulator"
ADB="$SDK_PATH/platform-tools/adb"

echo "Starting emulator..."
"$EMULATOR" -avd flutter_emulator -no-boot-anim &
EMULATOR_PID=$!

echo "Waiting for emulator to boot (30 seconds)..."
sleep 30

echo "Launching app..."
cd "$(dirname "$0")"
flutter run -v

wait $EMULATOR_PID
