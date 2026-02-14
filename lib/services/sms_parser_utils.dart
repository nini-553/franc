
/// Modular regex patterns for parsing Indian bank transactional SMS.
/// Handles common formats: Rs./INR amounts, UPI VPA, merchant names, etc.
class SmsParserUtils {
  SmsParserUtils._();

  // --- AMOUNT ---
  // Rs. 250, Rs 250, INR 1,200, ₹250.00, Rs.1,200.50
  static final RegExp _amountPattern1 = RegExp(
    r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );
  // Amount debited/spent: "250 debited", "1,200 spent"
  static final RegExp _amountPattern2 = RegExp(
    r'(?:debited|spent|deducted|withdrawn|paid|transfer(?:red)?)\s*(?:rs\.?|inr|₹)?\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );
  // Amount before currency: "250 rs", "1,200 inr"
  static final RegExp _amountPattern3 = RegExp(
    r'([\d,]+(?:\.\d{1,2})?)\s*(?:rs\.?|inr|rupees?)',
    caseSensitive: false,
  );

  /// Extract amount from SMS body. Returns null if not found.
  static double? extractAmount(String body) {
    if (body.isEmpty) return null;
    final lower = body.toLowerCase();

    // Try patterns in order of reliability
    for (final pattern in [_amountPattern1, _amountPattern2, _amountPattern3]) {
      final match = pattern.firstMatch(lower);
      if (match != null) {
        final raw = (match.group(1) ?? '').replaceAll(',', '');
        final value = double.tryParse(raw);
        if (value != null && value > 0) return value;
      }
    }
    return null;
  }

  // --- MERCHANT / RECEIVER ---
  // "debited to UPI VPA abc@ybl" or "to UPI id xyz@paytm"
  static final RegExp _upiVpaPattern = RegExp(
    r'(?:upi\s*vpa|upi\s*id|vpa|to)\s*([a-zA-Z0-9._-]+@[a-zA-Z0-9.]+)',
    caseSensitive: false,
  );
  // "Cr. to merchant@bank" or "credited to xyz"
  static final RegExp _crToPattern = RegExp(
    r'cr\.?\s*to\s+([a-zA-Z0-9._-]+(?:@[a-zA-Z0-9.]+)?)',
    caseSensitive: false,
  );
  // "spent on AMAZON", "paid to JOHN", "transfer to JOHN"
  static final RegExp _spentOnPattern = RegExp(
    r'(?:spent\s*on|paid\s*to|transfer\s*to|purchase\s*at)\s+([A-Za-z0-9\s]+?)(?:\s+on\s|\s*\.|,|$)',
    caseSensitive: false,
  );
  // "at AMAZON", "at Flipkart"
  static final RegExp _atMerchantPattern = RegExp(
    r'(?:at|on)\s+([A-Za-z][A-Za-z0-9\s]{1,30}?)(?:\s+on\s|\s*\.|,|$|avail|bal)',
    caseSensitive: false,
  );
  // Known merchant keywords
  static const List<String> _merchantKeywords = [
    'amazon', 'flipkart', 'zomato', 'swiggy', 'uber', 'ola', 'rapido',
    'paytm', 'phonepe', 'gpay', 'airtel', 'jio', 'vi', 'vodafone',
    'zepto', 'blinkit', 'netflix', 'spotify', 'hotstar',
  ];

  /// Extract merchant/receiver name. Returns null if not confidently found.
  static String? extractMerchant(String body) {
    if (body.isEmpty) return null;
    final lower = body.toLowerCase();

    // UPI VPA - extract and clean
    var match = _upiVpaPattern.firstMatch(lower);
    if (match != null) {
      final vpa = match.group(1) ?? '';
      return _cleanUpiToName(vpa);
    }

    // Cr. to pattern (debit destination)
    match = _crToPattern.firstMatch(lower);
    if (match != null) {
      var raw = (match.group(1) ?? '').trim();
      if (raw.endsWith('.')) raw = raw.substring(0, raw.length - 1);
      return _cleanUpiToName(raw);
    }

    // "spent on X", "paid to X", "transfer to X"
    match = _spentOnPattern.firstMatch(body); // Use original for case
    if (match != null) {
      final name = (match.group(1) ?? '').trim();
      if (name.length >= 2 && name.length <= 40) return _capitalize(name);
    }

    // "at AMAZON"
    match = _atMerchantPattern.firstMatch(body);
    if (match != null) {
      final name = (match.group(1) ?? '').trim();
      if (name.length >= 2) return _capitalize(name);
    }

    // Generic UPI ID pattern
    match = RegExp(r'([a-zA-Z0-9._-]+@[a-zA-Z0-9.]+)').firstMatch(lower);
    if (match != null) {
      return _cleanUpiToName(match.group(1) ?? '');
    }

    // Known merchant keywords
    for (final kw in _merchantKeywords) {
      if (lower.contains(kw)) return _capitalize(kw);
    }

    return null;
  }

  static String _cleanUpiToName(String vpa) {
    if (vpa.contains('@')) {
      final namePart = vpa.split('@').first;
      if (RegExp(r'^\d+$').hasMatch(namePart)) return 'UPI Transfer';
      if (namePart.contains('.')) return _capitalize(namePart.split('.').first);
      return _capitalize(namePart);
    }
    return _capitalize(vpa);
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  /// Public helper to capitalize a string for display.
  static String capitalize(String s) => _capitalize(s);

  // --- MODE (UPI/IMPS/ATM/Card/NetBanking) ---
  static const Map<RegExp, String> _modePatterns = {
    RegExp(r'\bupi\b', caseSensitive: false): 'UPI',
    RegExp(r'\bimps\b', caseSensitive: false): 'IMPS',
    RegExp(r'\bneft\b', caseSensitive: false): 'NEFT',
    RegExp(r'\brtgs\b', caseSensitive: false): 'RTGS',
    RegExp(r'\batm\b', caseSensitive: false): 'ATM',
    RegExp(r'\bdebit\s*card\b', caseSensitive: false): 'Card',
    RegExp(r'\bcard\b', caseSensitive: false): 'Card',
    RegExp(r'\bnet\s*banking\b', caseSensitive: false): 'NetBanking',
    RegExp(r'\bpos\b', caseSensitive: false): 'Card',
  };

  /// Extract payment mode from SMS.
  static String extractMode(String body) {
    if (body.isEmpty) return 'UPI'; // Default
    final lower = body.toLowerCase();
    for (final entry in _modePatterns.entries) {
      if (entry.key.hasMatch(lower)) return entry.value;
    }
    return 'UPI';
  }

  // --- AVAILABLE BALANCE ---
  // "Avl Bal: Rs. 15,230", "Available balance is Rs 10,450", "Avail Bal Rs.1234"
  static final RegExp _balancePattern1 = RegExp(
    r'(?:avl\s*bal|avail(?:able)?\s*bal(?:ance)?|a/c\s*bal|clear\s*bal)[:\s]*(?:rs\.?|inr|₹)?\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );
  static final RegExp _balancePattern2 = RegExp(
    r'(?:balance|bal)\s*(?:is|:)\s*(?:rs\.?|inr|₹)?\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  /// Extract available balance from SMS. Returns null if not found.
  static double? extractBalance(String body) {
    if (body.isEmpty) return null;
    final lower = body.toLowerCase();
    for (final pattern in [_balancePattern1, _balancePattern2]) {
      final match = pattern.firstMatch(lower);
      if (match != null) {
        final raw = (match.group(1) ?? '').replaceAll(',', '');
        final value = double.tryParse(raw);
        if (value != null && value >= 0) return value;
      }
    }
    return null;
  }

  // --- DATE / TIME ---
  // Format: (2026:01:29 08:17:19)
  static final RegExp _dateTimePattern1 = RegExp(
    r'\((\d{4}):(\d{2}):(\d{2})\s+(\d{2}):(\d{2}):(\d{2})\)',
  );
  // DD/MM/YYYY HH:MM or DD-MM-YYYY
  static final RegExp _dateTimePattern2 = RegExp(
    r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})\s+(\d{1,2}):(\d{2})',
  );
  static final RegExp _dateTimePattern3 = RegExp(
    r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})',
  );
  // DD-MMM-YYYY format
  static final RegExp _dateTimePattern4 = RegExp(
    r'(\d{1,2})-([A-Za-z]{3})-(\d{2,4})',
  );

  static const List<String> _months = [
    'jan', 'feb', 'mar', 'apr', 'may', 'jun',
    'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
  ];

  /// Extract date and time from SMS. Returns null if not found.
  static DateTime? extractDateTime(String body) {
    if (body.isEmpty) return null;

    // (2026:01:29 08:17:19)
    var match = _dateTimePattern1.firstMatch(body);
    if (match != null) {
      try {
        final s = '${match.group(1)}-${match.group(2)}-${match.group(3)} '
            '${match.group(4)}:${match.group(5)}:${match.group(6)}';
        return DateTime.parse(s);
      } catch (_) {}
    }

    // DD/MM/YYYY HH:MM
    match = _dateTimePattern2.firstMatch(body);
    if (match != null) {
      try {
        var d = int.parse(match.group(1)!);
        var m = int.parse(match.group(2)!);
        var y = int.parse(match.group(3)!);
        if (y < 100) y += 2000;
        final h = int.parse(match.group(4)!);
        final min = int.parse(match.group(5)!);
        return DateTime(y, m, d, h, min);
      } catch (_) {}
    }

    // DD/MM/YYYY
    match = _dateTimePattern3.firstMatch(body);
    if (match != null) {
      try {
        var d = int.parse(match.group(1)!);
        var m = int.parse(match.group(2)!);
        var y = int.parse(match.group(3)!);
        if (y < 100) y += 2000;
        return DateTime(y, m, d);
      } catch (_) {}
    }

    // DD-MMM-YYYY
    match = _dateTimePattern4.firstMatch(body);
    if (match != null) {
      try {
        final d = int.parse(match.group(1)!);
        final monStr = (match.group(2) ?? '').toLowerCase();
        final mi = _months.indexWhere((m) => monStr.startsWith(m));
        if (mi >= 0) {
          var y = int.parse(match.group(3)!);
          if (y < 100) y += 2000;
          return DateTime(y, mi + 1, d);
        }
      } catch (_) {}
    }

    return null;
  }

  /// Extract transaction reference ID.
  static String? extractReference(String body) {
    final match = RegExp(
      r'(?:ref|reference|txn|transaction)[:\s]*([A-Z0-9]{6,})',
      caseSensitive: false,
    ).firstMatch(body);
    return match?.group(1);
  }
}
