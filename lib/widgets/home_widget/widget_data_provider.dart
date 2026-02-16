import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Provides formatted data for home screen widgets
/// Fetches expense and budget data and formats it for widget display
class WidgetDataProvider {
  /// Get all data needed for the widget
  static Future<Map<String, dynamic>> getWidgetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get user ID (assuming it's stored after login)
      final userId = prefs.getString('userId') ?? '';
      
      // Get current month expenses from cache
      // In your actual app, this would fetch from ExpenseService
      final cachedExpenses = prefs.getString('cached_expenses_$userId') ?? '[]';
      final expenses = jsonDecode(cachedExpenses) as List;
      
      // Calculate total spent this month
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      
      double totalSpent = 0.0;
      Map<String, dynamic>? lastExpense;
      
      for (var expense in expenses) {
        final expenseDate = DateTime.parse(expense['date'] ?? expense['timestamp']);
        if (expenseDate.year == currentMonth.year && 
            expenseDate.month == currentMonth.month) {
          totalSpent += (expense['amount'] as num).toDouble();
          
          // Track most recent expense
          if (lastExpense == null || 
              expenseDate.isAfter(DateTime.parse(lastExpense['date'] ?? lastExpense['timestamp']))) {
            lastExpense = expense;
          }
        }
      }
      
      // Get monthly budget (default 15000 if not set)
      final monthlyBudget = prefs.getDouble('monthly_budget') ?? 15000.0;
      
      // Calculate remaining and percentage
      final remaining = monthlyBudget - totalSpent;
      final percentage = monthlyBudget > 0 ? (totalSpent / monthlyBudget * 100) : 0.0;
      
      // Format last expense time
      String lastExpenseTime = 'No expenses';
      String lastExpenseCategory = '';
      double lastExpenseAmount = 0.0;
      String lastExpenseIcon = '🛒';
      
      if (lastExpense != null) {
        final expenseDate = DateTime.parse(lastExpense['date'] ?? lastExpense['timestamp']);
        lastExpenseTime = _formatTime(expenseDate);
        lastExpenseCategory = lastExpense['category'] ?? 'Other';
        lastExpenseAmount = (lastExpense['amount'] as num).toDouble();
        lastExpenseIcon = _getCategoryIcon(lastExpenseCategory);
      }
      
      // Determine color based on percentage
      final colorHex = _getColorForPercentage(percentage);
      
      return {
        'spent': totalSpent,
        'budget': monthlyBudget,
        'remaining': remaining,
        'percentage': percentage,
        'lastCategory': lastExpenseCategory,
        'lastAmount': lastExpenseAmount,
        'lastTime': lastExpenseTime,
        'lastIcon': lastExpenseIcon,
        'colorHex': colorHex,
        'hasExpenses': expenses.isNotEmpty,
      };
    } catch (e) {
      print('Error getting widget data: $e');
      return _getEmptyData();
    }
  }
  
  /// Format timestamp to human-readable time
  static String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      // Today
      final hour = date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return 'Today, $displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  /// Get emoji icon for category
  static String _getCategoryIcon(String category) {
    final categoryLower = category.toLowerCase();
    
    if (categoryLower.contains('food') || categoryLower.contains('dining')) {
      return '🍕';
    } else if (categoryLower.contains('transport') || categoryLower.contains('travel')) {
      return '🚗';
    } else if (categoryLower.contains('shop') || categoryLower.contains('shopping')) {
      return '🛒';
    } else if (categoryLower.contains('entertainment') || categoryLower.contains('fun')) {
      return '🎬';
    } else if (categoryLower.contains('groceries')) {
      return '🥬';
    } else if (categoryLower.contains('health') || categoryLower.contains('medical')) {
      return '💊';
    } else if (categoryLower.contains('education') || categoryLower.contains('study')) {
      return '📚';
    } else if (categoryLower.contains('bills') || categoryLower.contains('utilities')) {
      return '💡';
    } else {
      return '💰';
    }
  }
  
  /// Get color based on budget usage percentage
  static String _getColorForPercentage(double percentage) {
    if (percentage <= 50) {
      return '#00FF88'; // Bright green - on track
    } else if (percentage <= 75) {
      return '#FFC107'; // Yellow - warning
    } else if (percentage <= 90) {
      return '#FF9800'; // Orange - high usage
    } else {
      return '#FF5252'; // Red - over budget
    }
  }
  
  /// Return empty/default data when no expenses exist
  static Map<String, dynamic> _getEmptyData() {
    return {
      'spent': 0.0,
      'budget': 15000.0,
      'remaining': 15000.0,
      'percentage': 0.0,
      'lastCategory': 'No expenses',
      'lastAmount': 0.0,
      'lastTime': 'Start tracking!',
      'lastIcon': '📊',
      'colorHex': '#00FF88',
      'hasExpenses': false,
    };
  }
  
  /// Format currency with rupee symbol
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
  
  /// Format currency with $ symbol (as per design)
  static String formatCurrencyDollar(double amount) {
    return '${amount.toStringAsFixed(0)} \$';
  }
}
