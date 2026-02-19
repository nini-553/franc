import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service for scanning receipts using Gemini API via backend
class ReceiptScanningService {
  static const String baseUrl = 'https://undiyal-backend-8zqj.onrender.com';

  /// Scan receipt image using Gemini API
  /// Returns extracted data: amount, merchant, date, category, etc.
  static Future<Map<String, dynamic>?> scanReceipt(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('ReceiptScanning: Image file does not exist');
        return null;
      }

      final imageBytes = await file.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      debugPrint('ReceiptScanning: Sending receipt image to Gemini API');

      final uri = Uri.parse('$baseUrl/test-gemini');
      
      // Send image as base64 in JSON body
      final body = jsonEncode({
        'image': base64Image,
        'image_format': 'base64',
      });

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('ReceiptScanning: Request timeout');
          throw Exception('Request timeout');
        },
      );

      debugPrint('ReceiptScanning Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Parse the response - adjust based on your backend's response format
        // Expected format might be:
        // { "amount": 500, "merchant": "Store Name", "date": "2024-01-15", "category": "Food & Drink", ... }
        
        return _parseGeminiResponse(data);
      } else {
        debugPrint('ReceiptScanning failed: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error scanning receipt: $e');
      return null;
    }
  }

  /// Parse Gemini API response into structured data
  static Map<String, dynamic> _parseGeminiResponse(Map<String, dynamic> data) {
    // Extract fields from response - adjust based on your backend's actual response format
    double? amount;
    String merchant = '';
    String category = 'Others';
    DateTime? date;
    String paymentMethod = 'Cash';

    // Try different possible response formats
    if (data.containsKey('amount')) {
      final amt = data['amount'];
      if (amt is num) {
        amount = amt.toDouble();
      } else if (amt is String) {
        amount = double.tryParse(amt.replaceAll(RegExp(r'[^\d.]'), ''));
      }
    }

    if (data.containsKey('merchant') || data.containsKey('merchant_name') || data.containsKey('store')) {
      merchant = (data['merchant'] ?? data['merchant_name'] ?? data['store'] ?? '').toString();
    }

    if (data.containsKey('category')) {
      category = data['category'].toString();
    }

    if (data.containsKey('date') || data.containsKey('transaction_date')) {
      final dateStr = (data['date'] ?? data['transaction_date'] ?? '').toString();
      if (dateStr.isNotEmpty) {
        date = DateTime.tryParse(dateStr);
      }
    }

    if (data.containsKey('payment_method') || data.containsKey('paymentMethod')) {
      paymentMethod = (data['payment_method'] ?? data['paymentMethod'] ?? 'Cash').toString();
    }

    return {
      'amount': amount,
      'merchant': merchant,
      'category': category,
      'date': date ?? DateTime.now(),
      'paymentMethod': paymentMethod,
      'confidence': data['confidence'] != null ? (data['confidence'] as num).toDouble() : 0.8,
    };
  }
}
