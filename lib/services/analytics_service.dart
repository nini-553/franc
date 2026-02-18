
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import 'transaction_storage_service.dart';

class AnalyticsService {
  static const String _budgetKey = 'monthly_budget';

  /// Get comprehensive analytics data
  static Future<Map<String, dynamic>> getAnalyticsData() async {
    final transactions = await TransactionStorageService.getAllTransactions();
    final budget = await getBudget();
    final now = DateTime.now();
    
    // Filter for current month
    final thisMonthTransactions = transactions.where((t) => 
      t.date.year == now.year && t.date.month == now.month
    ).toList();

    // Category Breakdown (combine real + mock data for demo)
    final categoryTotals = <String, double>{};
    
    // Add real transactions
    for (var t in thisMonthTransactions) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0.0) + t.amount;
    }

    // Calculate total spent (real + mock for demo)
    final realTotalSpent = thisMonthTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final totalSpent = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    
    // Add mock data for better demo visualization (only if no real data exists)
    if (categoryTotals.isEmpty || categoryTotals.values.fold(0.0, (a, b) => a + b) < 1000) {
      final mockCategories = {
        'Food & Drink': 2500.0,
        'Transport': 1800.0,
        'Shopping': 1200.0,
        'Entertainment': 800.0,
        'Bills': 1500.0,
        'Groceries': 900.0,
      };
      
      // Add mock data to existing categories or create new ones
      mockCategories.forEach((category, amount) {
        categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
      });
    }
    
    // Weekly Data (Last 7 days)
    final weeklyData = _getWeeklyData(transactions, now);
    
    // Monthly Data (Last 6 months)
    final monthlyData = _getMonthlyData(transactions, now);
    
    // Insights
    final insights = _generateInsights(categoryTotals, totalSpent, budget, transactions);

    return {
      'totalSpent': totalSpent,
      'budget': budget,
      'categoryTotals': categoryTotals,
      'weeklyData': weeklyData,
      'monthlyData': monthlyData,
      'insights': insights,
    };
  }

  /// Get today's total spent
  static Future<double> getTodaySpent() async {
    final transactions = await TransactionStorageService.getAllTransactions();
    final now = DateTime.now();
    return transactions
        .where((t) => 
          t.date.year == now.year && 
          t.date.month == now.month && 
          t.date.day == now.day)
        .fold<double>(0.0, (double sum, Transaction t) => sum + t.amount);
  }

  /// Get daily limit (Monthly Budget / 30)
  static Future<double> getDailyLimit() async {
    final budget = await getBudget();
    return budget / 30.0;
  }

  /// Get stored budget or default
  static Future<double> getBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_budgetKey) ?? 5000.0;
  }

  /// Save budget
  static Future<void> setBudget(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, amount);
  }

  static List<Map<String, dynamic>> _getWeeklyData(List<Transaction> transactions, DateTime now) {
    List<Map<String, dynamic>> data = [];
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    // Mock data for better demo visualization
    final mockWeeklyAmounts = [850.0, 1200.0, 650.0, 2100.0, 980.0, 1800.0, 1350.0];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      
      // Get real transactions for this day
      final realDayTotal = transactions
          .where((t) => 
            t.date.year == day.year && t.date.month == day.month && t.date.day == day.day)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      // Combine real data with mock data for demo
      final mockAmount = mockWeeklyAmounts[6 - i];
      final totalAmount = realDayTotal + (i == 0 ? 0 : mockAmount); // Today shows only real data

      data.add({
        'label': weekdays[day.weekday - 1],
        'amount': totalAmount,
        'isToday': i == 0,
      });
    }
    return data;
  }

  static List<Map<String, dynamic>> _getMonthlyData(List<Transaction> transactions, DateTime now) {
    List<Map<String, dynamic>> data = [];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    // Mock data for better demo visualization (past months)
    final mockMonthlyAmounts = [15000.0, 18500.0, 12300.0, 22100.0, 16800.0, 0.0]; // Current month = 0

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      
      // Get real transactions for this month
      final realMonthTotal = transactions
          .where((t) => 
            t.date.year == month.year && t.date.month == month.month)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      // Combine real data with mock data for demo
      final mockAmount = mockMonthlyAmounts[5 - i];
      final totalAmount = realMonthTotal + (i == 0 ? 0 : mockAmount); // Current month shows only real data

      data.add({
        'label': months[month.month - 1],
        'amount': totalAmount,
        'isCurrentMonth': i == 0,
      });
    }
    return data;
  }

  static List<String> _generateInsights(
    Map<String, double> categoryTotals, 
    double totalSpent, 
    double budget,
    List<Transaction> allTransactions
  ) {
    final insights = <String>[];

    // 1. Highest Category
    if (categoryTotals.isNotEmpty) {
      final sorted = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topCat = sorted.first;
      insights.add("You spent most on ${topCat.key} this month ${_getCategoryEmoji(topCat.key)}");
    }

    // 2. Budget Check
    if (totalSpent > budget) {
      insights.add("You've exceeded your monthly budget 😬");
    } else if (totalSpent > budget * 0.9) {
      insights.add("You're close to your budget limit! ⚠️");
    } else if (totalSpent < budget * 0.5 && DateTime.now().day > 15) {
      insights.add("Great saving! Under 50% of budget 💚");
    }

    // 3. Weekend Spender?
    final weekendSpend = allTransactions
        .where((t) => t.date.weekday >= 6 && DateTime.now().difference(t.date).inDays < 7)
        .fold<double>(0.0, (double sum, Transaction t) => sum + t.amount);
    if (weekendSpend > totalSpent * 0.4 && totalSpent > 0) {
      insights.add("Weekend vibes! 40% spent this weekend 🎉");
    }

    // Default Fallback
    if (insights.isEmpty) {
      insights.add("Track more expenses to see insights! 📊");
    }

    return insights.take(3).toList();
  }

  static String _getCategoryEmoji(String category) {
     final map = {
      'Food & Drink': '🍔',
      'Shopping': '🛍️',
      'Transport': '🚕',
      'Entertainment': '🎬',
      'Groceries': '🍎',
      'Bills': '⚡',
      'Health': '💊',
      'Education': '📚',
    };
    return map[category] ?? '✨';
  }
}
