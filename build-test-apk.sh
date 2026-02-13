#!/bin/bash

echo "Building Undiyal APK for testing..."

# Build version WITH SMS permissions
echo "Building APK WITH SMS permissions..."
flutter build apk --release --dart-define=FLUTTER_WEB_CANVASKIT_URL=canvaskit/ --dart-define=INCLUDE_SMS_PERMISSIONS=true
cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/undiyal-with-sms.apk

# Build version WITHOUT SMS permissions
echo "Building APK WITHOUT SMS permissions..."
cp android/app/src/main/AndroidManifest-no-sms.xml android/app/src/main/AndroidManifest.xml
flutter build apk --release --dart-define=FLUTTER_WEB_CANVASKIT_URL=canvaskit/ --dart-define=INCLUDE_SMS_PERMISSIONS=false
cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/undiyal-no-sms.apk

# Restore original manifest
git checkout android/app/src/main/AndroidManifest.xml

echo "Build complete! APKs available:"
echo "- With SMS: build/app/outputs/flutter-apk/undiyal-with-sms.apk"
echo "- Without SMS: build/app/outputs/flutter-apk/undiyal-no-sms.apk"
echo ""
echo "Test the 'no-sms' version first - it should install without Play Protect blocking."
