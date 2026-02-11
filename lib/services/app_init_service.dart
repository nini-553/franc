import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import 'notification_service.dart';
import 'sms_expense_service.dart';
import 'transaction_storage_service.dart';

/// Service to initialize app and read SMS on launch
class AppInitService {
  /// Initialize app: Setup services without requesting permissions
  static Future<void> initialize() async {
    try {
      // PERFROM ONE-TIME CLEANUP (Migration to real data only)
      final prefs = await SharedPreferences.getInstance();
      final hasCleaned = prefs.getBool('has_cleaned_v2_data') ?? false; // Unique key for this update

      if (!hasCleaned) {
        debugPrint('Performing one-time data cleanup...');
        await TransactionStorageService.clearAllData();
        await prefs.setBool('has_cleaned_v2_data', true);
        debugPrint('One-time cleanup complete.');
      }

      // Initialize Notifications (without requesting permission)
      await NotificationService.initialize();
      debugPrint('Notification service initialized');
    } catch (e) {
      debugPrint('Error initializing app services: $e');
    }
  }

  /// Initialize SMS detection after permissions are granted
  static Future<void> initializeSmsDetection() async {
    try {
      // Check if SMS permission is granted
      final hasPermission = await SmsExpenseService.hasSmsPermission();
      
      if (hasPermission) {
        debugPrint('SMS permission granted, detecting expenses...');
        
        // Read last 50 SMS messages for initial detection
        final detectedTransactions = await SmsExpenseService.detectExpensesFromSms(
          limit: 50, 
        );

        if (detectedTransactions.isNotEmpty) {
          debugPrint('Detected & Saved transaction from SMS');
        }
      } else {
        debugPrint('SMS permission not granted');
      }
    } catch (e) {
      debugPrint('Error initializing SMS expense detection: $e');
    }
  }

  /// Periodic SMS check (can be called from background or periodically)
  static Future<void> checkForNewExpenses() async {
    try {
      if (await SmsExpenseService.hasSmsPermission()) {
        // Read SMS from last 24 hours
        final detectedTransactions = await SmsExpenseService.detectExpensesFromSms(
          since: const Duration(hours: 24),
          limit: 50,
        );

        if (detectedTransactions.isNotEmpty) {
          final List<Transaction> newTransactions = [];
          for (var tx in detectedTransactions) {
            final isDuplicate = await SmsExpenseService.isDuplicate(tx);
            if (!isDuplicate) {
              newTransactions.add(tx);
            }
          }

          if (newTransactions.isNotEmpty) {
            await SmsExpenseService.saveTransactions(newTransactions);
            debugPrint('Detected ${newTransactions.length} new expenses');
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking for new expenses: $e');
    }
  }
}

