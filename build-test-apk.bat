@echo off
echo Building Undiyal APK for testing...

REM Build version WITH SMS permissions
echo Building APK WITH SMS permissions...
flutter build apk --release --dart-define=FLUTTER_WEB_CANVASKIT_URL=canvaskit/ --dart-define=INCLUDE_SMS_PERMISSIONS=true
copy build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\undiyal-with-sms.apk

REM Build version WITHOUT SMS permissions
echo Building APK WITHOUT SMS permissions...
copy android\app\src\main\AndroidManifest-no-sms.xml android\app\src\main\AndroidManifest.xml
flutter build apk --release --dart-define=FLUTTER_WEB_CANVASKIT_URL=canvaskit/ --dart-define=INCLUDE_SMS_PERMISSIONS=false
copy build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\undiyal-no-sms.apk

REM Restore original manifest
git checkout android\app\src\main\AndroidManifest.xml

echo Build complete! APKs available:
echo - With SMS: build\app\outputs\flutter-apk\undiyal-with-sms.apk
echo - Without SMS: build\app\outputs\flutter-apk\undiyal-no-sms.apk
echo.
echo Test the 'no-sms' version first - it should install without Play Protect blocking.
