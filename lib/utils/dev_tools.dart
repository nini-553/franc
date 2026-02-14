import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../services/sms_expense_service.dart';

/// Development tools for testing
class DevTools {
  /// Force cleanup and remove all mock data
  static Future<void> forceCleanup() async {
    if (kDebugMode) {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear all transaction data
      await SmsExpenseService.clearAllData();
      
      // Reset cleanup flag to force it to run again
      await prefs.setBool('has_cleaned_v2_data', false);
      
      debugPrint('✓ Force cleanup complete - all mock data removed');
      debugPrint('✓ Cleanup flag reset - will run on next app init');
    }
  }

  /// Reset bank setup status (for testing blocked screen)
  static Future<void> resetBankSetup() async {
    if (kDebugMode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('has_completed_bank_setup');
      await prefs.remove('bank_balance_last_bank');
      await prefs.remove('bank_balance_timestamp');
      debugPrint('✓ Bank setup reset - restart app to see blocked screen');
    }
  }

  /// Reset all onboarding flags
  static Future<void> resetOnboarding() async {
    if (kDebugMode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('has_requested_permissions');
      await prefs.remove('has_completed_bank_setup');
      debugPrint('✓ Onboarding reset - restart app');
    }
  }

  /// Clear all app data (logout + reset)
  static Future<void> clearAllData() async {
    if (kDebugMode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('✓ All data cleared - restart app');
    }
  }
}
