@echo off
echo ===========================================
echo Undiyal APK Installation Troubleshooting
echo ===========================================
echo.
echo If APK won't install, try these methods:
echo.
echo METHOD 1: Direct Install via ADB
echo ---------------------------------
echo 1. Enable USB Debugging on phone:
echo    Settings -^> Developer Options -^> USB Debugging
echo 2. Connect phone via USB
echo 3. Run: adb install -r -d undiyal-debug.apk
echo.
echo METHOD 2: Use Flutter Run
echo --------------------------
echo 1. Connect phone via USB with debugging enabled
echo 2. Run: flutter run --release
echo This installs and runs directly
echo.
echo METHOD 3: Android Studio Install
echo --------------------------------
echo 1. Open android/ folder in Android Studio
echo 2. Build -^> Build Bundle(s) / APK(s) -^> Build APK(s)
echo 3. Click 'locate' and install from there
echo.
echo METHOD 4: Remove SMS Permissions Test
echo ---------------------------------------
echo Try the version without SMS permissions:
echo Use manifest: AndroidManifest-no-sms.xml
echo Build: flutter build apk --release
echo.
echo ===========================================
pause
