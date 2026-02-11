import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Utility class to check and debug permission status
class PermissionChecker {
  /// Check all app permissions and log their status
  static Future<Map<String, PermissionStatus>> checkAllPermissions() async {
    final permissions = {
      'SMS': await Permission.sms.status,
      'Notification': await Permission.notification.status,
      'Camera': await Permission.camera.status,
      'Photos': await Permission.photos.status,
      'Storage': await Permission.storage.status,
    };

    if (kDebugMode) {
      debugPrint('=== Permission Status ===');
      permissions.forEach((name, status) {
        debugPrint('$name: ${status.toString()}');
      });
      debugPrint('========================');
    }

    return permissions;
  }

  /// Check if critical permissions are granted
  static Future<bool> hasCriticalPermissions() async {
    final smsStatus = await Permission.sms.status;
    final notificationStatus = await Permission.notification.status;
    
    return smsStatus.isGranted && notificationStatus.isGranted;
  }

  /// Check if SMS permission is granted
  static Future<bool> hasSmsPermission() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  /// Check if notification permission is granted
  static Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission (for receipt scanning)
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      debugPrint('Camera permission permanently denied');
      return false;
    }

    final result = await Permission.camera.request();
    return result.isGranted;
  }

  /// Request photos permission (for image picker)
  static Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.status;
    
    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      debugPrint('Photos permission permanently denied');
      return false;
    }

    final result = await Permission.photos.request();
    return result.isGranted;
  }
}
