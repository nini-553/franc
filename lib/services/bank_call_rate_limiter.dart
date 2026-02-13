import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to manage rate limiting for bank missed call balance checks
/// Banks typically allow 3-5 missed calls per day
class BankCallRateLimiter {
  static const String _callsKey = 'bank_missed_calls_log';
  static const int maxCallsPerDay = 3; // Conservative limit for most banks

  /// Check if a missed call can be made for a specific bank
  static Future<bool> canMakeCall(String bankCode) async {
    final prefs = await SharedPreferences.getInstance();
    final callsJson = prefs.getString(_callsKey);
    
    if (callsJson == null) return true;
    
    final List<dynamic> calls = jsonDecode(callsJson);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Count calls made today for this bank
    int callsToday = 0;
    for (final call in calls) {
      final callTime = DateTime.fromMillisecondsSinceEpoch(call['timestamp']);
      final callDay = DateTime(callTime.year, callTime.month, callTime.day);
      
      if (callDay == today && call['bank'] == bankCode) {
        callsToday++;
      }
    }
    
    return callsToday < maxCallsPerDay;
  }

  /// Record a missed call for a specific bank
  static Future<void> recordCall(String bankCode) async {
    final prefs = await SharedPreferences.getInstance();
    final callsJson = prefs.getString(_callsKey);
    
    List<dynamic> calls = [];
    if (callsJson != null) {
      calls = jsonDecode(callsJson);
    }
    
    // Add new call
    calls.add({
      'bank': bankCode,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    // Clean up old calls (older than 7 days)
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    calls.removeWhere((call) {
      final callTime = DateTime.fromMillisecondsSinceEpoch(call['timestamp']);
      return callTime.isBefore(cutoff);
    });
    
    await prefs.setString(_callsKey, jsonEncode(calls));
  }

  /// Get the number of calls made today for a specific bank
  static Future<int> getCallsToday(String bankCode) async {
    final prefs = await SharedPreferences.getInstance();
    final callsJson = prefs.getString(_callsKey);
    
    if (callsJson == null) return 0;
    
    final List<dynamic> calls = jsonDecode(callsJson);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int callsToday = 0;
    for (final call in calls) {
      final callTime = DateTime.fromMillisecondsSinceEpoch(call['timestamp']);
      final callDay = DateTime(callTime.year, callTime.month, callTime.day);
      
      if (callDay == today && call['bank'] == bankCode) {
        callsToday++;
      }
    }
    
    return callsToday;
  }

  /// Get remaining calls for today for a specific bank
  static Future<int> getRemainingCalls(String bankCode) async {
    final callsToday = await getCallsToday(bankCode);
    return maxCallsPerDay - callsToday;
  }

  /// Get time until next reset (midnight)
  static Duration getTimeUntilReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }

  /// Clear all call history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_callsKey);
  }
}
