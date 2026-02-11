# Permission Verification Checklist

## Pre-Build Verification

### Android Configuration
- [x] AndroidManifest.xml declares all required permissions
  - [x] READ_SMS
  - [x] RECEIVE_SMS
  - [x] POST_NOTIFICATIONS
  - [x] CAMERA
  - [x] READ_EXTERNAL_STORAGE (maxSdkVersion="32")
  - [x] WRITE_EXTERNAL_STORAGE (maxSdkVersion="32")
  - [x] READ_MEDIA_IMAGES
  - [x] INTERNET

- [x] ProGuard rules configured for all plugins
  - [x] Flutter core classes
  - [x] permission_handler
  - [x] flutter_local_notifications
  - [x] flutter_sms_inbox
  - [x] image_picker
  - [x] shared_preferences
  - [x] path_provider
  - [x] home_widget

- [x] Build.gradle.kts properly configured
  - [x] minifyEnabled = true for release
  - [x] shrinkResources = true for release
  - [x] ProGuard files referenced

### iOS Configuration
- [x] Info.plist contains usage descriptions
  - [x] NSCameraUsageDescription
  - [x] NSPhotoLibraryUsageDescription

### Flutter Code
- [x] Permission request screen created
- [x] Auth gate integrates permission flow
- [x] App initialization doesn't request permissions automatically
- [x] SMS detection initialized after permissions granted
- [x] Permission checker utility created

## Build & Test Checklist

### Debug Build Testing
```bash
flutter clean
flutter pub get
flutter run
```

- [ ] App launches successfully
- [ ] After signup, permission screen appears
- [ ] SMS permission request dialog shows
- [ ] Notification permission request dialog shows
- [ ] Can skip permissions and app continues
- [ ] Can grant permissions and app continues
- [ ] SMS detection works after granting permissions

### Release Build Testing
```bash
flutter clean
flutter pub get
flutter build apk --release
```

- [ ] Build completes without errors
- [ ] Install APK on device
- [ ] App launches without crashes
- [ ] Permission flow works in release build
- [ ] SMS reading works in release build
- [ ] Notifications work in release build
- [ ] Camera/photo picker works when needed

### Permission Scenarios to Test

#### Scenario 1: First Install - Grant All
1. [ ] Install app
2. [ ] Sign up
3. [ ] Permission screen appears
4. [ ] Tap "Grant Permissions"
5. [ ] Grant SMS permission
6. [ ] Grant Notification permission
7. [ ] Navigate to home screen
8. [ ] Verify SMS detection works
9. [ ] Verify notifications can be shown

#### Scenario 2: First Install - Deny All
1. [ ] Install app
2. [ ] Sign up
3. [ ] Permission screen appears
4. [ ] Tap "Skip for Now"
5. [ ] Navigate to home screen
6. [ ] Verify app works (without SMS detection)
7. [ ] Verify manual expense entry works

#### Scenario 3: Permanently Denied
1. [ ] Install app
2. [ ] Sign up
3. [ ] Deny SMS permission twice
4. [ ] Verify "Open Settings" dialog appears
5. [ ] Tap "Open Settings"
6. [ ] Verify Settings app opens
7. [ ] Grant permission in Settings
8. [ ] Return to app
9. [ ] Verify permission is now granted

#### Scenario 4: Camera Permission (On-Demand)
1. [ ] Navigate to add expense screen
2. [ ] Tap "Scan Receipt" or camera button
3. [ ] Camera permission dialog appears
4. [ ] Grant permission
5. [ ] Camera opens successfully
6. [ ] Can take photo

#### Scenario 5: Photo Library Permission (On-Demand)
1. [ ] Navigate to add expense screen
2. [ ] Tap "Choose from Gallery"
3. [ ] Photo permission dialog appears
4. [ ] Grant permission
5. [ ] Gallery opens successfully
6. [ ] Can select photo

### ProGuard Verification

#### Check ProGuard is Working
```bash
# Build release APK
flutter build apk --release

# Check APK size (should be smaller than debug)
ls -lh build/app/outputs/flutter-apk/app-release.apk

# Verify no ProGuard warnings in build output
# Look for "Note: ..." or "Warning: ..." messages
```

- [ ] Release APK builds successfully
- [ ] No ProGuard warnings about missing classes
- [ ] APK size is reasonable (smaller than debug)
- [ ] All features work in release build

#### Common ProGuard Issues to Check
- [ ] Permission handler classes not stripped
- [ ] SMS inbox plugin classes not stripped
- [ ] Notification plugin classes not stripped
- [ ] No crashes when requesting permissions
- [ ] No crashes when reading SMS
- [ ] No crashes when showing notifications

### Device Testing Matrix

Test on multiple Android versions:
- [ ] Android 13+ (API 33+) - POST_NOTIFICATIONS required
- [ ] Android 12 (API 31-32) - New photo picker
- [ ] Android 11 (API 30) - Scoped storage
- [ ] Android 10 (API 29) - Legacy storage

### Logs to Check

Enable verbose logging and check for:
```bash
adb logcat | grep -i "permission\|sms\|notification"
```

- [ ] "SMS permission granted" appears after granting
- [ ] "Notification permission granted" appears after granting
- [ ] "Detected & Saved transaction from SMS" appears
- [ ] No permission-related crashes
- [ ] No ProGuard-related crashes

## Post-Release Monitoring

### Crashlytics/Analytics
- [ ] Monitor crash reports for permission-related crashes
- [ ] Track permission grant/deny rates
- [ ] Monitor SMS detection success rate
- [ ] Track notification delivery rate

### User Feedback
- [ ] Users can successfully grant permissions
- [ ] SMS detection works reliably
- [ ] Notifications appear as expected
- [ ] No reports of crashes on permission requests

## Rollback Plan

If issues are found:
1. Revert to previous version
2. Investigate specific ProGuard rule causing issue
3. Add more specific keep rules
4. Test thoroughly before re-release

## Sign-Off

- [ ] All checklist items completed
- [ ] Tested on multiple devices
- [ ] No critical issues found
- [ ] Ready for production release

**Tested By:** _______________
**Date:** _______________
**Devices Tested:** _______________
**Build Version:** _______________
