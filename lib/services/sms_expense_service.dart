import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import 'notification_service.dart';
import 'home_widget_service.dart';
import 'expense_service.dart';

/// Service for automatically detecting expenses from SMS messages
/// Works fully offline, no backend connection required
class SmsExpenseService {
  static const String _processedSmsKey = 'processed_sms_references';
  static const String _transactionsKey = 'stored_transactions';
  
  // Keywords that indicate transactional SMS (debit/expense)
  static const List<String> _transactionKeywords = [
    'dr', 'debit', 'debited', 'paid', 'spent', 'upi', 'txn', 'transaction',
    'withdrawn', 'deducted', 'rs.', 'inr', 'rupees', 'credited to'
  ];
  
  // Keywords to ignore (OTP, promotional, credit)
  static const List<String> _ignoreKeywords = [
    'otp', 'verification', 'promo', 'offer', 'discount', 'cr', 'credit',
    'credited', 'received', 'deposit', 'balance', 'statement'
  ];

  /// Request SMS permission from user
  static Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.status;
    if (status.isGranted) {
      return true;
    }
    
    if (status.isPermanentlyDenied) {
      debugPrint('SMS permission permanently denied.');
      return false;
    }
    
    debugPrint('Requesting SMS permission...');
    final result = await Permission.sms.request();
    debugPrint('SMS permission result: $result');
    return result.isGranted;
  }

  /// Check if SMS permission is granted
  static Future<bool> hasSmsPermission() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }



  /// DEMO: Read and parse SMS messages for expense detection
  /// Returns list of detected transactions
  static Future<List<Transaction>> detectExpensesFromSms({
    int? limit = 5,
    Duration? since,
  }) async {
    // 1. Check permissions
    if (!await hasSmsPermission()) {
      debugPrint('SMS permission not granted');
      // For demo, try to request it if not granted
      if (!await requestSmsPermission()) {
        return [];
      }
    }

    try {
      // Initialize SMS reader
      final SmsQuery query = SmsQuery();
      
      // 2. Read recent SMS (Last 1-5 messages is enough)
      List<SmsMessage> messages = await query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: limit ?? 5,
      );

      final existingTransactions = await getStoredTransactions();
      
      // 3. Process messages
      for (var message in messages) {
        final body = message.body ?? '';
        
        // Check if this SMS was already processed
        final processedIds = await _getProcessedReferences();
        if (processedIds.contains(message.id.toString())) {
          debugPrint('Skipping processed msg ID: ${message.id}');
          continue;
        }
        
        // 4. Parse the SMS using robust logic
        final parsedData = _parseSmsForExpense(body);
        
        if (parsedData == null) {
           debugPrint('Failed to parse/ignore SMS');
           continue;
        }

        debugPrint('Parsed data: $parsedData');
        
        double amount = parsedData['amount'];
        String merchantName = parsedData['merchant'];
        String? refNumber = parsedData['reference'];
        String paymentMethod = parsedData['paymentMethod'];

        // LOW CONFIDENCE / UNKNOWN MERCHANT CHECK
        if (merchantName == 'Unknown Merchant' || merchantName.isEmpty) {
           debugPrint('Low confidence transaction detected. Triggering notification.');
           await NotificationService.showExpenseNotification(
             amount: amount,
             date: message.date ?? DateTime.now(),
           );
           // Mark as processed so we don't notify again
           await _markSmsAsProcessed(message.id.toString());
           continue; // Do NOT save automatically
        }

        // 6. Check for duplicates (Prevent duplicates in storage)
        final isDuplicate = existingTransactions.any((tx) {
           if (refNumber != null && tx.referenceNumber == refNumber) return true;
           // Fuzzy match: same amount, same merchant, same day
           final sameDay = tx.date.year == (message.date?.year ?? 0) &&
                           tx.date.month == (message.date?.month ?? 0) &&
                           tx.date.day == (message.date?.day ?? 0);
           return tx.amount == amount && tx.merchant == merchantName && sameDay; 
        });

        if (isDuplicate) {
          debugPrint('Skipping duplicate transaction for $merchantName');
          await _markSmsAsProcessed(message.id.toString());
          continue; 
        }

        // 5. Populate transaction fields
        final transaction = Transaction(
          id: _generateTransactionId(),
          amount: amount,
          merchant: merchantName,
          category: _categorizeExpense(merchantName, amount)['category'],
          paymentMethod: paymentMethod,
          isAutoDetected: true,
          date: message.date ?? DateTime.now(),
          referenceNumber: refNumber,
          confidenceScore: 1.0, 
        );

        debugPrint('Auto-detected transaction: ${transaction.merchant} - ${transaction.amount}');

        // 6. Save ONLY ONE auto-detected transaction (per run cycle, typically)
        await saveTransactions([transaction]);
        await _markSmsAsProcessed(message.id.toString());

        // Sync to backend
        try {
          await ExpenseService.addExpense(transaction);
        } catch (e) {
          debugPrint('Failed to sync SMS transaction to backend: $e');
        }
        
        return [transaction]; // Return immediately after processing one
            }

      return [];
    } catch (e) {
      debugPrint('Error reading SMS: $e');
      return [];
    }
  }

  /// Parse SMS message to extract expense information
  /// Returns map with amount, merchant, date, type, reference, paymentMethod
  /// Returns null if SMS is not a transactional expense
  static Map<String, dynamic>? _parseSmsForExpense(String smsBody) {
    // 1. NORMALIZE UNICODE CHARACTERS TO ASCII
    // Bank of Baroda and others sometimes use specialized fonts
    String body = smsBody.toLowerCase().trim();
    body = body.replaceAll('𝖣𝗋', 'dr')
               .replaceAll('𝖿𝗋𝗈𝗆', 'from')
               .replaceAll('𝖺𝗇𝖽', 'and')
               .replaceAll('𝖢𝗋', 'cr')
               .replaceAll('𝗍𝗈', 'to');

    // Check if SMS contains transaction keywords
    final hasTransactionKeyword = _transactionKeywords.any((keyword) => body.contains(keyword));
    if (!hasTransactionKeyword) {
      return null;
    }

    // Check if SMS should be ignored (OTP, promotional, credit)
    final shouldIgnore = _ignoreKeywords.any((keyword) => body.contains(keyword));
    if (shouldIgnore) {
      // Logic for "Cr." in the user's SMS:
      // "Dr. from ... and Cr. to ..." -> This IS a debit for the user.
      // But standard "Cr." usually means money coming IN.
      // We must be careful. The user's pattern is explicit: "Dr. from A/C...".
      // So if it contains "dr. from", it's likely an expense, identifying it as a debit
      if (!body.contains('dr. from') && !body.contains('debited')) {
         if (body.contains('cr') || body.contains('credit') || body.contains('credited')) {
           return null;
         }
      }
    }

    // Extract amount using regex patterns
    double? amount;
    String? amountStr;
    
    // Pattern: "Rs.300.00" or "Rs 105.00" or "₹105.00"
    final pattern1 = RegExp(r'(?:rs\.?|inr|₹)\s*(\d+(?:\.\d{2})?)', caseSensitive: false);
    final match1 = pattern1.firstMatch(body);
    if (match1 != null) {
      amountStr = match1.group(1);
      amount = double.tryParse(amountStr ?? '');
    }

    if (amount == null || amount <= 0) {
      return null; // No valid amount found
    }

    // Determine transaction type (debit/credit)
    String transactionType = 'debit';
    // User's specific format "Dr. from" is explicitly a debit
    if (body.contains('dr. from')) {
      transactionType = 'debit';
    } else if (body.contains('cr') || body.contains('credit') || body.contains('credited')) {
       // If it doesn't have "dr. from" but has "credit", it's income (ignore for now)
       if (!body.contains('and cr. to')) { // "and Cr. to" implies destination of debit
          return null; 
       }
    }

    // Extract merchant/UPI ID
    String merchant = 'Unknown Merchant';
    
    // Pattern for user's SMS: "and Cr. to <merchant>."
    // e.g. "and Cr. to dharini1463@okicici." or "and Cr. to zepto.payu@axisbank."
    final crToPattern = RegExp(r'cr\.\s*to\s+([^\s]+)', caseSensitive: false);
    final crToMatch = crToPattern.firstMatch(body);
    
    if (crToMatch != null) {
      String rawMerchant = crToMatch.group(1) ?? '';
      // Clean up trailing dots or generic text
      if (rawMerchant.endsWith('.')) rawMerchant = rawMerchant.substring(0, rawMerchant.length - 1);
      
      // If it looks like a UPI ID (contains @), try to make it readable
      if (rawMerchant.contains('@')) {
         final parts = rawMerchant.split('@');
         if (parts.isNotEmpty) {
           String namePart = parts[0];
           // Heuristic: If it has dots like "zepto.payu", take the first part
           if (namePart.contains('.')) {
              namePart = namePart.split('.')[0];
           }
           // Remove numbers if it looks like a phone number UPI (9361...)
           if (RegExp(r'^\d+$').hasMatch(namePart)) {
             merchant = 'UPI Transfer'; // fallback for raw phone numbers
           } else {
             merchant = namePart; // Use the name part (e.g., "zepto", "dharini")
           }
         }
      } else {
        merchant = rawMerchant;
      }
    } else {
        // Fallback patterns
        
        // Pattern 1: UPI ID
        final upiPattern = RegExp(r'(\w+(?:\.\w+)*@\w+)', caseSensitive: false);
        final upiMatch = upiPattern.firstMatch(body);
        if (upiMatch != null) {
           merchant = 'UPI Payment'; // Generic if we cant parse name
        }

        // Pattern 3: Common merchant names
        final merchantKeywords = [
          'amazon', 'flipkart', 'zomato', 'swiggy', 'uber', 'ola', 'rapido',
          'paytm', 'phonepe', 'gpay', 'airtel', 'jio', 'vi', 'vodafone', 'zepto', 'blinkit'
        ];
        for (var keyword in merchantKeywords) {
          if (body.contains(keyword)) {
            merchant = keyword.substring(0, 1).toUpperCase() + keyword.substring(1);
            break;
          }
        }
    }

    // Capitalize first letter
    if (merchant != 'Unknown Merchant' && merchant.isNotEmpty) {
       merchant = merchant[0].toUpperCase() + merchant.substring(1);
    }

    // Extract reference information
    String? referenceNumber;
    final refPattern = RegExp(r'(?:ref|reference|txn|transaction)[:\s]*([A-Z0-9]{6,})', caseSensitive: false);
    final refMatch = refPattern.firstMatch(body);
    if (refMatch != null) {
      referenceNumber = refMatch.group(1);
    }
    
    // Extract Date from SMS content if available: (2026:01:29 08:17:19)
    DateTime transactionDate = DateTime.now();
    final datePattern = RegExp(r'\((\d{4}:\d{2}:\d{2}\s+\d{2}:\d{2}:\d{2})\)');
    final dateMatch = datePattern.firstMatch(smsBody); // Use original body for case/format
    if (dateMatch != null) {
      try {
        final dateStr = dateMatch.group(1)?.replaceAll(':', '-'); // 2026-01-29 08-17-19
        // Fix time part back to colons: 2026-01-29 08:17:19
        if (dateStr != null) {
           final parts = dateStr.split(' ');
           if (parts.length == 2) {
             final timePart = parts[1].replaceAll('-', ':');
             transactionDate = DateTime.parse('${parts[0]} $timePart');
           }
        }
      } catch (e) {
        debugPrint('Error parsing date from SMS: $e');
      }
    }

    String paymentMethod = 'UPI'; // Default for these bank alerts
    if (body.contains('card') || body.contains('debit card')) paymentMethod = 'Card';

    return {
      'amount': amount,
      'merchant': merchant,
      'date': transactionDate,
      'type': transactionType,
      'reference': referenceNumber,
      'paymentMethod': paymentMethod,
    };
  }

  /// AI-style expense categorization using rule-based + heuristic logic
  /// Returns category and confidence score (0-1)
  static Map<String, dynamic> _categorizeExpense(String merchant, double amount) {
    final merchantLower = merchant.toLowerCase();
    double confidence = 0.0;
    String category = 'Others';

    // Food & Drink category
    final foodKeywords = ['zomato', 'swiggy', 'uber eats', 'food', 'restaurant', 'cafe', 
                          'starbucks', 'mcdonald', 'kfc', 'pizza', 'burger', 'hotel'];
    if (foodKeywords.any((keyword) => merchantLower.contains(keyword))) {
      category = 'Food & Drink';
      confidence = 0.9;
      return {'category': category, 'confidence': confidence};
    }

    // Transport category
    final transportKeywords = ['uber', 'ola', 'rapido', 'taxi', 'cab', 'metro', 'bus', 
                               'train', 'railway', 'flight', 'airline'];
    if (transportKeywords.any((keyword) => merchantLower.contains(keyword))) {
      category = 'Transport';
      confidence = 0.9;
      return {'category': category, 'confidence': confidence};
    }

    // Shopping category
    final shoppingKeywords = ['amazon', 'flipkart', 'myntra', 'nykaa', 'shop', 'store', 
                               'mall', 'market'];
    if (shoppingKeywords.any((keyword) => merchantLower.contains(keyword))) {
      category = 'Shopping';
      confidence = 0.85;
      return {'category': category, 'confidence': confidence};
    }

    // Bills category
    final billsKeywords = ['airtel', 'jio', 'vi', 'vodafone', 'bsnl', 'electricity', 
                           'water', 'gas', 'internet', 'broadband', 'dth', 'cable'];
    if (billsKeywords.any((keyword) => merchantLower.contains(keyword))) {
      category = 'Bills';
      confidence = 0.9;
      return {'category': category, 'confidence': confidence};
    }

    // Entertainment category
    final entertainmentKeywords = ['netflix', 'spotify', 'prime', 'hotstar', 'youtube', 
                                   'movie', 'cinema', 'theater', 'game'];
    if (entertainmentKeywords.any((keyword) => merchantLower.contains(keyword))) {
      category = 'Entertainment';
      confidence = 0.85;
      return {'category': category, 'confidence': confidence};
    }

    // Education category
    final educationKeywords = ['university', 'college', 'school', 'tuition', 'course', 
                               'book', 'stationery'];
    if (educationKeywords.any((keyword) => merchantLower.contains(keyword))) {
      category = 'Education';
      confidence = 0.8;
      return {'category': category, 'confidence': confidence};
    }

    // Health category
    final healthKeywords = ['pharmacy', 'medical', 'hospital', 'clinic', 'doctor', 
                            'medicine', 'apollo', 'fortis'];
    if (healthKeywords.any((keyword) => merchantLower.contains(keyword))) {
      category = 'Health';
      confidence = 0.85;
      return {'category': category, 'confidence': confidence};
    }

    // Groceries (heuristic: medium amounts, common grocery keywords)
    final groceryKeywords = ['grocery', 'supermarket', 'dmart', 'big bazaar', 'reliance'];
    if (groceryKeywords.any((keyword) => merchantLower.contains(keyword)) ||
        (amount >= 100 && amount <= 2000 && merchantLower.contains('store'))) {
      category = 'Groceries';
      confidence = 0.7;
      return {'category': category, 'confidence': confidence};
    }

    // Default to Others with low confidence
    confidence = 0.3;
    return {'category': category, 'confidence': confidence};
  }

  /// Get list of already processed SMS message IDs
  static Future<Set<String>> _getProcessedReferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refsJson = prefs.getString(_processedSmsKey);
      if (refsJson != null) {
        final List<dynamic> refsList = jsonDecode(refsJson);
        return refsList.map((e) => e.toString()).toSet();
      }
    } catch (e) {
      debugPrint('Error reading processed references: $e');
    }
    return {};
  }

  /// Mark SMS message as processed to avoid duplicates
  static Future<void> _markSmsAsProcessed(String smsId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final processedRefs = await _getProcessedReferences();
      processedRefs.add(smsId);
      
      final refsList = processedRefs.toList();
      await prefs.setString(_processedSmsKey, jsonEncode(refsList));
    } catch (e) {
      debugPrint('Error marking SMS as processed: $e');
    }
  }

  /// Generate unique transaction ID
  static String _generateTransactionId() {
    return 'sms_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Save detected transactions to local storage
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingTransactions = await getStoredTransactions();
      
      // Merge with existing transactions, avoiding duplicates
      final Map<String, Transaction> transactionMap = {};
      
      // Add existing transactions
      for (var tx in existingTransactions) {
        transactionMap[tx.id] = tx;
      }
      
      // Add new transactions (will overwrite if same ID)
      for (var tx in transactions) {
        transactionMap[tx.id] = tx;
      }
      
      // Convert to JSON and save
      final transactionsJson = transactionMap.values.map((tx) => _transactionToJson(tx)).toList();
      await prefs.setString(_transactionsKey, jsonEncode(transactionsJson));

      // UPDATE HOME WIDGET
      await HomeWidgetService.updateWidgetData();
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  /// Get stored transactions from local storage
  static Future<List<Transaction>> getStoredTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getString(_transactionsKey);
      
      if (transactionsJson != null) {
        final List<dynamic> transactionsList = jsonDecode(transactionsJson);
        return transactionsList.map((json) => _transactionFromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error reading stored transactions: $e');
    }
    return [];
  }

  /// Convert Transaction to JSON
  static Map<String, dynamic> _transactionToJson(Transaction tx) {
    return {
      'id': tx.id,
      'amount': tx.amount,
      'merchant': tx.merchant,
      'category': tx.category,
      'date': tx.date.toIso8601String(),
      'paymentMethod': tx.paymentMethod,
      'status': tx.status,
      'receiptUrl': tx.receiptUrl,
      'isRecurring': tx.isRecurring,
      'isAutoDetected': tx.isAutoDetected,
      'referenceNumber': tx.referenceNumber,
      'confidenceScore': tx.confidenceScore,
    };
  }

  /// Convert JSON to Transaction
  static Transaction _transactionFromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      merchant: json['merchant'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String? ?? 'completed',
      receiptUrl: json['receiptUrl'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      isAutoDetected: json['isAutoDetected'] as bool? ?? false,
      referenceNumber: json['referenceNumber'] as String?,
      confidenceScore: json['confidenceScore'] != null ? (json['confidenceScore'] as num).toDouble() : null,
    );
  }

  /// Check for duplicate transactions based on reference number and amount
  static Future<bool> isDuplicate(Transaction transaction) async {
    if (transaction.referenceNumber == null) {
      return false; // Can't check duplicates without reference
    }
    
    final existingTransactions = await getStoredTransactions();
    return existingTransactions.any((tx) =>
        tx.referenceNumber == transaction.referenceNumber &&
        tx.amount == transaction.amount &&
        tx.date.difference(transaction.date).abs().inDays < 1);
  }

  /// Clear all stored transactions and processed references
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_transactionsKey);
      await prefs.remove(_processedSmsKey);
      debugPrint('All transaction data cleared.');
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }
}


/// Helper to take first N chars safely
extension StringExtension on String {
  String take(int n) => length > n ? substring(0, n) : this;
}
