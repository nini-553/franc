import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import 'notification_service.dart';
import 'sms_expense_service.dart';
import 'sms_notification_listener.dart';
import 'transaction_storage_service.dart';

/// Service to initialize app and read SMS on launch
class AppInitService {
  /// Initialize app: Setup services without requesting permissions
  static Future<void> initialize() async {
    try {
      // PERFORM ONE-TIME CLEANUP (Migration to real data only)
      final prefs = await SharedPreferences.getInstance();
      final hasCleaned = prefs.getBool('has_cleaned_v2_data') ?? false;

      debugPrint('Checking cleanup status: has_cleaned_v2_data = $hasCleaned');
      
      if (!hasCleaned) {
        debugPrint('Performing one-time data cleanup...');
        await TransactionStorageService.clearAllData();
        await prefs.setBool('has_cleaned_v2_data', true);
        debugPrint('One-time cleanup complete.');
        
        // Verify the flag was set
        final verifyCleaned = prefs.getBool('has_cleaned_v2_data');
        debugPrint('Verification: has_cleaned_v2_data = $verifyCleaned');
      } else {
        debugPrint('One-time cleanup already completed, skipping...');
      }

      // Initialize Notifications (without requesting permission)
      await NotificationService.initialize();
      debugPrint('Notification service initialized');

      // DO NOT request SMS permission here - it will be requested after login/signup
      debugPrint('App initialization complete (permissions will be requested after auth)');
    } catch (e) {
      debugPrint('Error initializing app services: $e');
    }
  }

  /// Initialize SMS detection after permissions are granted
  static Future<void> initializeSmsDetection() async {
    try {
      debugPrint('=== INITIALIZING SMS DETECTION ===');
      
      // Check if SMS permission is granted
      final hasPermission = await SmsExpenseService.hasSmsPermission();
      debugPrint('SMS permission status: $hasPermission');

      if (hasPermission) {
        debugPrint('SMS permission granted, detecting expenses...');

        // Calculate messages from current month for comprehensive analysis
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final daysSinceStartOfMonth = now.difference(startOfMonth).inDays;

        debugPrint('Analyzing SMS from last $daysSinceStartOfMonth days (current month)');
        debugPrint('Will scan up to 500 messages');

        // Read SMS from current month (suppress notifications during init)
        final detectedTransactions =
            await SmsExpenseService.detectExpensesFromSms(
          since: Duration(days: daysSinceStartOfMonth),
          limit: 500,
          suppressNotifications: true,
        );

        if (detectedTransactions.isNotEmpty) {
          debugPrint('✓ Detected & Saved ${detectedTransactions.length} transactions from SMS');
          for (var tx in detectedTransactions) {
            debugPrint('  - ${tx.merchant}: ₹${tx.amount} (${tx.category})');
          }
        } else {
          debugPrint('⚠ No new transactions detected from SMS');
          debugPrint('  Possible reasons:');
          debugPrint('  1. No transaction SMS in inbox');
          debugPrint('  2. All SMS already processed');
          debugPrint('  3. SMS format not recognized');
        }
        
        debugPrint('=== SMS DETECTION COMPLETE ===');
        SmsNotificationListener.markInitializationComplete();
      } else {
        debugPrint('✗ SMS permission not granted - cannot detect expenses');
        SmsNotificationListener.markInitializationComplete();
      }
    } catch (e) {
      debugPrint('✗ Error initializing SMS expense detection: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  /// Periodic SMS check (can be called from background or periodically)
  static Future<void> checkForNewExpenses() async {
    try {
      if (await SmsExpenseService.hasSmsPermission()) {
        // Read SMS from last 24 hours
        final detectedTransactions =
            await SmsExpenseService.detectExpensesFromSms(
          since: const Duration(hours: 24),
          limit: 100,
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
