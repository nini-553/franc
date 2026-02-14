class ReceiptParser {
  /// Parse receipt image - returns empty data; user enters details manually.
  /// Future: integrate OCR for auto-extraction.
  static Future<Map<String, dynamic>> parseReceipt(String imagePath) async {
    return {
      'amount': null,
      'merchant': '',
      'category': 'Others',
      'date': DateTime.now(),
      'paymentMethod': 'Cash',
      'confidence': 0.0,
    };
  }

  /// Parse from camera - returns empty data; user enters details manually.
  static Future<Map<String, dynamic>> parseReceiptFromCamera() async {
    return {
      'amount': null,
      'merchant': '',
      'category': 'Others',
      'date': DateTime.now(),
      'paymentMethod': 'Cash',
      'confidence': 0.0,
      'receiptImagePath': null,
    };
  }

  static String detectCategory(String merchant) {
    final categoryMap = {
      'starbucks': 'Food & Drink',
      'mcdonalds': 'Food & Drink',
      'amazon': 'Shopping',
      'walmart': 'Groceries',
      'target': 'Shopping',
      'uber': 'Transport',
      'lyft': 'Transport',
      'netflix': 'Entertainment',
      'spotify': 'Entertainment',
      'apple': 'Shopping',
    };

    final key = merchant.toLowerCase();
    for (var entry in categoryMap.entries) {
      if (key.contains(entry.key)) {
        return entry.value;
      }
    }

    return 'Others';
  }
}