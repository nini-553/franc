import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'user_service.dart';

/// Service to parse bank balance SMS messages
class BalanceSmsParser {
  /// Stream controller for balance updates
  static final StreamController<Map<String, dynamic>> _balanceUpdateController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  /// Stream that emits when a new balance is detected
  static Stream<Map<String, dynamic>> get onBalanceUpdate => _balanceUpdateController.stream;
  /// Bank patterns for balance detection - improved regex for various SMS formats
  static final Map<String, RegExp> _bankPatterns = {
    'BOB': RegExp(
      r'(?:Clear\s*Bal|Balance).*?(?:Rs\.?|INR)\s*([0-9,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ),
    'CUB': RegExp(
      r'(?:Available\s*Balance|Avail\s*Bal|A\/c\s*Balance).*?(?:INR|Rs\.?)\s*([0-9,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ),
    'IOB': RegExp(
      r'(?:Available\s*Balance|Avail\s*Bal|A\/c\s*Balance).*?(?:INR|Rs\.?)\s*([0-9,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ),
    'HDFC': RegExp(
      r'(?:Available\s*Balance|Avail\s*Bal|balance).*?(?:INR|Rs\.?)\s*([0-9,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ),
    'AXIS': RegExp(
      r'(?:Available\s*Balance|Avail\s*Bal).*?(?:INR|Rs\.?)\s*([0-9,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ),
    'SBI': RegExp(
      r'(?:Avl\s*Bal|Available\s*Balance|A\/c\s*Bal).*?(?:Rs\.?|INR)\s*([0-9,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ),
  };

  /// Bank identifiers in SMS sender or body
  static final Map<String, List<String>> _bankIdentifiers = {
    'BOB': ['Bank of Baroda', 'BOB', 'MConnect+'],
    'CUB': ['City Union Bank', 'CUB'],
    'IOB': ['Indian Overseas Bank', 'IOB'],
    'HDFC': ['HDFC Bank', 'HDFC'],
    'AXIS': ['Axis Bank', 'AXIS'],
    'SBI': ['SBI', 'State Bank'],
  };

  /// Check if SMS is a balance message and extract amount using keyword matching
  static Map<String, dynamic>? parseBalanceSms(String body, String? sender) {
    // Normalize text for better matching
    final normalizedBody = body.toLowerCase();
    final normalizedSender = sender?.toLowerCase() ?? '';

    // Keywords that indicate a balance SMS
    final balanceKeywords = [
      'balance', 'avail bal', 'available balance', 'avl bal', 
      'clear bal', 'a/c bal', 'account balance', 'bal:', 'balance:'
    ];
    
    // Check if this is a balance message
    bool isBalanceMessage = false;
    for (final keyword in balanceKeywords) {
      if (normalizedBody.contains(keyword)) {
        isBalanceMessage = true;
        break;
      }
    }
    
    if (!isBalanceMessage) {
      // Check sender patterns too
      final bankSenders = ['sbi', 'hdfc', 'axis', 'bob', 'iob', 'cub', 'bank'];
      bool isBankSender = false;
      for (final bank in bankSenders) {
        if (normalizedSender.contains(bank)) {
          isBankSender = true;
          break;
        }
      }
      if (!isBankSender) return null;
    }

    // Determine bank from sender or body
    String? detectedBank;
    for (final entry in _bankIdentifiers.entries) {
      for (final identifier in entry.value) {
        if (normalizedBody.contains(identifier.toLowerCase()) ||
            normalizedSender.contains(identifier.toLowerCase())) {
          detectedBank = entry.key;
          break;
        }
      }
      if (detectedBank != null) break;
    }

    // If no bank detected, check all patterns
    if (detectedBank == null) {
      for (final entry in _bankPatterns.entries) {
        final match = entry.value.firstMatch(body);
        if (match != null) {
          detectedBank = entry.key;
          break;
        }
      }
    }

    // Generic balance extraction if no specific bank detected but keywords present
    if (detectedBank == null && isBalanceMessage) {
      // Try generic balance pattern
      final genericPattern = RegExp(
        r'(?:balance|bal).*?(?:rs\.?|inr)\s*([0-9,]+(?:\.\d{1,2})?)',
        caseSensitive: false,
      );
      final match = genericPattern.firstMatch(body);
      if (match != null) {
        final amountStr = match.group(1) ?? '0';
        final amount = double.tryParse(amountStr.replaceAll(',', '')) ?? 0.0;
        if (amount > 0) {
          return {
            'bank': 'Unknown',
            'balance': amount,
            'rawAmount': amountStr,
          };
        }
      }
      return null;
    }

    // If still no bank, not a balance message
    if (detectedBank == null) return null;

    // Try to extract balance using bank-specific pattern
    final pattern = _bankPatterns[detectedBank];
    if (pattern == null) return null;

    final match = pattern.firstMatch(body);
    if (match != null) {
      final amountStr = match.group(1) ?? '0';
      final amount = double.tryParse(amountStr.replaceAll(',', '')) ?? 0.0;
      if (amount > 0) {
        return {
          'bank': detectedBank,
          'balance': amount,
          'rawAmount': amountStr,
        };
      }
    }

    // Fallback: try to find any amount near balance keywords
    final fallbackPattern = RegExp(
      r'(?:rs\.?|inr)\s*([0-9,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );
    final fallbackMatch = fallbackPattern.firstMatch(body);
    if (fallbackMatch != null) {
      final amountStr = fallbackMatch.group(1) ?? '0';
      final amount = double.tryParse(amountStr.replaceAll(',', '')) ?? 0.0;
      if (amount > 0) {
        return {
          'bank': detectedBank,
          'balance': amount,
          'rawAmount': amountStr,
        };
      }
    }

    return null;
  }

  /// Store balance in SharedPreferences and notify listeners
  static Future<void> storeBalance(String bank, double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bank_balance_$bank', balance);
    await prefs.setString('bank_balance_last_bank', bank);
    await prefs.setInt('bank_balance_timestamp', DateTime.now().millisecondsSinceEpoch);
    
    // Mark bank setup as completed
    await prefs.setBool('has_completed_bank_setup', true);
    
    // Sync with backend (non-blocking)
    _syncBalanceToBackend(bank, balance);
    
    // Notify listeners about the new balance
    _balanceUpdateController.add({
      'bank': bank,
      'balance': balance,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Sync balance to backend (PUT /user/balance) - non-blocking
  static void _syncBalanceToBackend(String bank, double balance) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      if (userEmail == null) return;

      // Sync to backend (fire and forget - don't block)
      UserService.updateBalance(
        email: userEmail,
        balance: balance,
        bank: bank,
      ).catchError((e) {
        debugPrint('Error syncing balance to backend: $e');
      });
    } catch (e) {
      // Silently fail - balance is stored locally anyway
      debugPrint('Error syncing balance to backend: $e');
    }
  }

  /// Get stored balance
  static Future<double?> getBalance(String bank) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('bank_balance_$bank');
  }

  /// Get the last detected bank balance
  static Future<Map<String, dynamic>?> getLastBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final bank = prefs.getString('bank_balance_last_bank');
    if (bank == null) return null;

    final balance = prefs.getDouble('bank_balance_$bank');
    final timestamp = prefs.getInt('bank_balance_timestamp');

    if (balance == null) return null;

    return {
      'bank': bank,
      'balance': balance,
      'timestamp': timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null,
    };
  }

  /// Get all stored balances
  static Future<Map<String, double>> getAllBalances() async {
    final prefs = await SharedPreferences.getInstance();
    final balances = <String, double>{};

    for (final bank in _bankPatterns.keys) {
      final balance = prefs.getDouble('bank_balance_$bank');
      if (balance != null) {
        balances[bank] = balance;
      }
    }

    return balances;
  }

  /// Clear all stored balances
  static Future<void> clearAllBalances() async {
    final prefs = await SharedPreferences.getInstance();
    for (final bank in _bankPatterns.keys) {
      await prefs.remove('bank_balance_$bank');
    }
    await prefs.remove('bank_balance_last_bank');
    await prefs.remove('bank_balance_timestamp');
  }

  /// Format bank code to full name
  static String getBankFullName(String code) {
    final names = {
      'BOB': 'Bank of Baroda',
      'CUB': 'City Union Bank',
      'IOB': 'Indian Overseas Bank',
      'HDFC': 'HDFC Bank',
      'AXIS': 'Axis Bank',
      'SBI': 'State Bank of India',
    };
    return names[code] ?? code;
  }
}
