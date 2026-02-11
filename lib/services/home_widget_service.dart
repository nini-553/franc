import 'package:home_widget/home_widget.dart';
import 'analytics_service.dart';
import 'streak_service.dart';

class HomeWidgetService {
  static const String appGroupId = 'group.com.undiyal.fintracker'; // Optional for iOS
  static const String androidWidgetName = 'UndiyalWidget'; // Provider class name

  /// Update data for all widgets
  static Future<void> updateWidgetData() async {
    try {
      // 1. Fetch Data
      final todaySpent = await AnalyticsService.getTodaySpent();
      final dailyLimit = await AnalyticsService.getDailyLimit();
      final streakData = await StreakService.getStreakData();
      final currentStreak = streakData['current'] ?? 0;
      final bestStreak = streakData['best'] ?? 0;

      // 2. Save Data to Widget Storage (Key-Value)
      await HomeWidget.saveWidgetData<double>('today_spent', todaySpent); // home_widget handles double/float conversion
      await HomeWidget.saveWidgetData<double>('daily_limit', dailyLimit);
      await HomeWidget.saveWidgetData<int>('current_streak', currentStreak);
      await HomeWidget.saveWidgetData<int>('best_streak', bestStreak);
      
      // Calculate progress (0.0 to 1.0)
      double progress = 0.0;
      if (dailyLimit > 0) {
        progress = (todaySpent / dailyLimit).clamp(0.0, 1.0);
      }
      await HomeWidget.saveWidgetData<double>('daily_progress', progress);

      // 3. Trigger Update
      // We update ALL widgets. The class name must match the Android receiver.
      // We will define 'UndiyalWidget' in AndroidManifest
      await HomeWidget.updateWidget(
        name: 'UndiyalWidgetProvider',
        iOSName: 'UndiyalWidget',
      );
      
      print('Widget data updated: Today: $todaySpent, Streak: $currentStreak');
    } catch (e) {
      print('Error updating widget data: $e');
    }
  }
}
