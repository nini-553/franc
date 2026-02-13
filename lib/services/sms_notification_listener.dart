import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sms_expense_service.dart';
import 'balance_sms_parser.dart';
import 'notification_service.dart';
import '../models/transaction_model.dart';

/// Service for listening to SMS notifications in real-time
/// More battery efficient than constant SMS scanning
class SmsNotificationListener {
  static const String _listenerEnabledKey = 'sms_listener_enabled';
  static const MethodChannel _channel = MethodChannel('sms_notification_listener');
  static bool _isListening = false;

  static final StreamController<Map<String, dynamic>> _smsController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of SMS notifications
  static Stream<Map<String, dynamic>> get smsStream => _smsController.stream;

  /// Check if notification listener is enabled
  static Future<bool> isListenerEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_listenerEnabledKey) ?? false;
    } catch (e) {
      debugPrint('Error checking listener status: $e');
      return false;
    }
  }

  /// Enable or disable SMS notification listener
  static Future<bool> setListenerEnabled(bool enabled) async {
    try {
      // Check SMS permission first
      final smsStatus = await Permission.sms.status;
      if (!smsStatus.isGranted) {
        debugPrint('SMS permission not granted');
        return false;
      }

      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_listenerEnabledKey, enabled);
      
      debugPrint('SMS notification listener ${enabled ? "enabled" : "disabled"}');
      
      if (enabled) {
        return await startListener();
      } else {
        return await stopListener();
      }
    } catch (e) {
      debugPrint('Error setting listener: $e');
      return false;
    }
  }

  /// Start listening for SMS notifications
  static Future<bool> startListener() async {
    try {
      // Check SMS permission first
      final smsStatus = await Permission.sms.status;
      if (!smsStatus.isGranted) {
        debugPrint('SMS permission not granted');
        return false;
      }

      _isListening = true;
      
      debugPrint('SMS notification listener started successfully (simulated)');
      return true;
    } catch (e) {
      debugPrint('Error starting SMS notification listener: $e');
      return false;
    }
  }

  /// Stop listening for SMS notifications
  static Future<bool> stopListener() async {
    try {
      _isListening = false;
      
      debugPrint('SMS notification listener stopped successfully (simulated)');
      return true;
    } catch (e) {
      debugPrint('Error stopping SMS notification listener: $e');
      return false;
    }
  }

  /// Check if listener is currently active
  static bool get isListening => _isListening;

  /// Open app notification settings for user
  static Future<void> openNotificationSettings() async {
    try {
      // Open Android notification listener settings
      await _channel.invokeMethod('openNotificationSettings');
      debugPrint('Opening Android notification listener settings');
    } catch (e) {
      debugPrint('Error opening notification settings: $e');
      // Fallback: just show message
      debugPrint('Please enable notification access in Android Settings > Accessibility > [App Name]');
    }
  }

  /// Initialize: listener service
  static Future<void> initialize() async {
    try {
      // Set up method channel handler
      _channel.setMethodCallHandler(_handleMethodCall);

      // Check if listener was previously enabled
      final prefs = await SharedPreferences.getInstance();
      final wasEnabled = prefs.getBool(_listenerEnabledKey) ?? false;

      if (wasEnabled) {
        debugPrint('SMS notification listener was previously enabled, attempting to start...');
        await startListener();
      }
    } catch (e) {
      debugPrint('Error initializing SMS notification listener: $e');
    }
  }

  /// Handle method calls from native NotificationListenerService
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onSmsReceived':
        if (call.arguments is String) {
          try {
            final smsData = jsonDecode(call.arguments as String) as Map<String, dynamic>;
            debugPrint('Received SMS from NotificationListenerService: ${smsData['body']}');

            // Add to stream
            _smsController.add(smsData);

            // Process the SMS
            await _processSmsNotification(smsData);
          } catch (e) {
            debugPrint('Error processing SMS notification: $e');
          }
        }
        break;
      default:
        debugPrint('Unknown method call: ${call.method}');
    }
  }

  /// Process SMS notification data
  static Future<void> _processSmsNotification(Map<String, dynamic> smsData) async {
    try {
      final body = smsData['body'] as String? ?? '';
      final sender = smsData['sender'] as String? ?? '';
      final timestamp = smsData['timestamp'] as int?;

      // Check if it's a balance SMS first
      final balanceData = BalanceSmsParser.parseBalanceSms(body, sender);
      if (balanceData != null) {
        debugPrint('Instant balance detection: ${balanceData['bank']} - Rs.${balanceData['balance']}');
        await BalanceSmsParser.storeBalance(
          balanceData['bank'] as String,
          balanceData['balance'] as double,
        );

        // Show notification for balance update
        await NotificationService.showBalanceNotification(
          bank: balanceData['bank'] as String,
          balance: balanceData['balance'] as double,
        );
        return;
      }

      // Parse for expense
      final parsedData = SmsExpenseService.parseSmsForExpense(body);
      if (parsedData != null) {
        debugPrint('Instant expense detection: ${parsedData['merchant']} - Rs.${parsedData['amount']}');

        // Check for duplicates
        final existingTransactions = await SmsExpenseService.getStoredTransactions();
        final isDuplicate = existingTransactions.any((tx) {
          final refNumber = parsedData['reference'] as String?;
          if (refNumber != null && tx.referenceNumber == refNumber) return true;

          // Fuzzy match: same amount, same merchant, same day
          final smsDate = timestamp != null
              ? DateTime.fromMillisecondsSinceEpoch(timestamp)
              : DateTime.now();
          final sameDay = tx.date.year == smsDate.year &&
                         tx.date.month == smsDate.month &&
                         tx.date.day == smsDate.day;
          return tx.amount == parsedData['amount'] &&
                 tx.merchant == parsedData['merchant'] &&
                 sameDay;
        });

        if (!isDuplicate) {
          // Create and save transaction instantly
          final transaction = Transaction(
            id: 'txn_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond % 1000}',
            amount: parsedData['amount'],
            merchant: parsedData['merchant'],
            category: SmsExpenseService.categorizeExpense(parsedData['merchant'], parsedData['amount'])['category'],
            paymentMethod: parsedData['paymentMethod'],
            isAutoDetected: true,
            date: timestamp != null
                ? DateTime.fromMillisecondsSinceEpoch(timestamp)
                : DateTime.now(),
            referenceNumber: parsedData['reference'],
            confidenceScore: 1.0,
            type: parsedData['type'] ?? 'expense',
          );

          await SmsExpenseService.saveTransactions([transaction]);

          // Show notification for new transaction
          await NotificationService.showExpenseNotification(
            amount: parsedData['amount'],
            date: timestamp != null
                ? DateTime.fromMillisecondsSinceEpoch(timestamp)
                : DateTime.now(),
          );

          debugPrint('Instant transaction saved: ${transaction.merchant} - ₹${transaction.amount}');
        } else {
          debugPrint('Duplicate transaction detected, skipping');
        }
      }
    } catch (e) {
      debugPrint('Error in instant SMS processing: $e');
    }
  }

  /// Request necessary permissions
  static Future<bool> requestPermissions() async {
    final notificationStatus = await Permission.notification.request();
    final smsStatus = await Permission.sms.request();
    
    return notificationStatus.isGranted && smsStatus.isGranted;
  }
}
