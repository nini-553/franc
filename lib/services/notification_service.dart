import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/globals.dart';
import '../screens/add_expense/manual_entry_screen.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'expense_alerts';
  static const String _channelName = 'Expense Alerts';
  static const String _channelDesc = 'Notifications for undetected expenses';

  // Friendly messages for ambiguous transactions
  static final List<String> _titles = [
    '💸 Did you just spend some money?',
    '👀 I saw a transaction!',
    '🤔 Help me categorize this',
    '🧾 New expense detected',
    '🤑 Cha-ching!',
    '🧐 Unknown purchase found'
  ];

  static final List<String> _bodies = [
    'Help me label it to keep your budget on track! 🚀',
    'Was that food, travel, or something else? Tap to tag it! 🍔✈️',
    'Quick check! Log this expense to stay organized. 📊',
    'Small logs lead to big savings! Tap to complete. 💰',
    'I couldn\'t figure out what this was. Can you help? 🤝',
    'Don\'t let this expense slip away! Log it now. 📝'
  ];

  /// Initialize notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create channel (required for Android 8.0+)
    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Request notification permission (Android 13+)
  static Future<bool> requestPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      debugPrint('Notification permission permanently denied.');
      return false;
    }

    final result = await Permission.notification.request();
    return result.isGranted;
  }

  /// Show notification for new expense
  static Future<void> showExpenseNotification({
    required double amount,
    required DateTime date,
  }) async {
    final title = _titles[DateTime.now().millisecond % _titles.length];
    final body = _bodies[DateTime.now().millisecond % _bodies.length];

    await _notificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode({'type': 'expense', 'amount': amount}),
    );
  }

  /// Show notification for balance update
  static Future<void> showBalanceNotification({
    required String bank,
    required double balance,
  }) async {
    await _notificationsPlugin.show(
      0,
      '💰 Balance Updated',
      '$bank: ₹${balance.toStringAsFixed(2)}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode({'type': 'balance', 'bank': bank, 'balance': balance}),
    );
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final amount = (data['amount'] as num).toDouble();
        final date = DateTime.parse(data['date']);

        // Navigate to Manual Entry Screen with pre-filled data
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(
            CupertinoPageRoute(
              builder: (context) => ManualEntryScreen(
                initialAmount: amount,
                initialDate: date,
              ),
            ),
          );
        } else {
            debugPrint('Navigator state is null, cannot navigate');
        }
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }
}
