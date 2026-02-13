import 'package:shared_preferences/shared_preferences.dart';

/// Global settings service to make budget and currency available throughout the app
class SettingsService {
  static const String _keyMonthlyBudget = 'monthly_budget';
  static const String _keyCurrency = 'currency';
  static const String _keyCurrencySymbol = 'currency_symbol';

  /// Default values
  static const double defaultBudget = 5000.0;
  static const String defaultCurrency = '₹ INR';
  static const String defaultCurrencySymbol = '₹';

  /// Currency symbols map
  static const Map<String, String> currencySymbols = {
    '₹ INR': '₹',
    '\$ USD': '\$',
    '€ EUR': '€',
    '£ GBP': '£',
    '¥ JPY': '¥',
  };

  /// Get monthly budget
  static Future<double> getMonthlyBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyMonthlyBudget) ?? defaultBudget;
  }

  /// Set monthly budget
  static Future<void> setMonthlyBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMonthlyBudget, budget);
  }

  /// Get currency string (e.g., "₹ INR")
  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrency) ?? defaultCurrency;
  }

  /// Set currency
  static Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, currency);
    // Also update the symbol
    await prefs.setString(_keyCurrencySymbol, currencySymbols[currency] ?? defaultCurrencySymbol);
  }

  /// Get currency symbol only (e.g., "₹")
  static Future<String> getCurrencySymbol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrencySymbol) ?? defaultCurrencySymbol;
  }

  /// Format amount with current currency symbol
  static Future<String> formatAmount(double amount) async {
    final symbol = await getCurrencySymbol();
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Format amount with symbol inline (for simple cases)
  static String formatAmountWithSymbol(double amount, String symbol) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Get all settings at once
  static Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'monthlyBudget': await getMonthlyBudget(),
      'currency': await getCurrency(),
      'currencySymbol': await getCurrencySymbol(),
    };
  }

  /// Clear all settings (logout)
  static Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMonthlyBudget);
    await prefs.remove(_keyCurrency);
    await prefs.remove(_keyCurrencySymbol);
  }
}
