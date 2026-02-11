import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserImagePath = 'user_image_path';
  static const String _keyCurrency = 'currency';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyBiometric = 'biometric_enabled';

  /// Save user profile data
  static Future<void> saveProfile({
    String? name,
    String? email,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString(_keyUserName, name);
    if (email != null) await prefs.setString(_keyUserEmail, email);
    if (imagePath != null) await prefs.setString(_keyUserImagePath, imagePath);
  }

  /// Get user profile data
  static Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyUserName);
    final email = prefs.getString(_keyUserEmail);
    final imagePath = prefs.getString(_keyUserImagePath);

    return {
      'name': name ?? 'Student',
      'email': email ?? 'student@undiyal.com',
      'imagePath': imagePath,
    };
  }

  /// Save single preference
  static Future<void> savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  /// Get all preferences
  static Future<Map<String, dynamic>> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'currency': prefs.getString(_keyCurrency) ?? '₹ INR',
      'notifications': prefs.getBool(_keyNotifications) ?? true,
      'biometric': prefs.getBool(_keyBiometric) ?? false,
    };
  }

  /// Clear all profile data (logout)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserImagePath);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyCurrency);
    await prefs.remove(_keyNotifications);
    await prefs.remove(_keyBiometric);
  }
}
