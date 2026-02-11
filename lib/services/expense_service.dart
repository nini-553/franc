import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import 'auth_service.dart';

class ExpenseService {
  static const String baseUrl = 'https://undiyal-backend-8zqj.onrender.com';

  /// Add a new expense (POST /expenses)
  static Future<bool> addExpense(Transaction transaction) async {
    try {
      final userEmail = await AuthService.getUserEmail();
      if (userEmail == null) {
        debugPrint('User email not found');
        return false;
      }

      // Backend expects user_email in body
      final body = {
        'user_email': userEmail,
        ...transaction.toJson(),
      };

      debugPrint('Adding expense: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse('$baseUrl/expenses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('Add Expense Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Failed to add expense: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding expense: $e');
      return false;
    }
  }

  /// Get expenses for the user (GET /expenses?user_email=...)
  static Future<List<Transaction>> getExpenses() async {
    try {
      final userEmail = await AuthService.getUserEmail();
      if (userEmail == null) {
        debugPrint('User email not found');
        return [];
      }

      debugPrint('Fetching expenses for: $userEmail');

      final response = await http.get(
        Uri.parse('$baseUrl/expenses?user_email=$userEmail'),
      );

      debugPrint('Get Expenses Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map && data.containsKey('expenses')) {
          list = data['expenses'];
        } else if (data is Map && data.containsKey('data')) {
          list = data['data'];
        }

        return list.map((json) => Transaction.fromJson(json)).toList();
      } else {
        debugPrint('Failed to fetch expenses: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
      return [];
    }
  }
}
