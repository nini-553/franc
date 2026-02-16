import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import 'widget_data_provider.dart';

/// Handles updating the home screen widget
/// Call updateWidget() whenever expenses are added/modified
class WidgetUpdater {
  static const String _androidWidgetName = 'UndiayalWidgetProvider';
  static const String _iOSWidgetName = 'UndiayalWidget';
  
  /// Update widget with latest expense data
  static Future<void> updateWidget() async {
    try {
      // Get fresh data
      final data = await WidgetDataProvider.getWidgetData();
      
      // Save data to shared storage for widget access
      await HomeWidget.saveWidgetData<double>('spent', data['spent']);
      await HomeWidget.saveWidgetData<double>('budget', data['budget']);
      await HomeWidget.saveWidgetData<double>('remaining', data['remaining']);
      await HomeWidget.saveWidgetData<double>('percentage', data['percentage']);
      await HomeWidget.saveWidgetData<String>('lastCategory', data['lastCategory']);
      await HomeWidget.saveWidgetData<double>('lastAmount', data['lastAmount']);
      await HomeWidget.saveWidgetData<String>('lastTime', data['lastTime']);
      await HomeWidget.saveWidgetData<String>('lastIcon', data['lastIcon']);
      await HomeWidget.saveWidgetData<String>('colorHex', data['colorHex']);
      await HomeWidget.saveWidgetData<bool>('hasExpenses', data['hasExpenses']);
      
      // Format display strings
      await HomeWidget.saveWidgetData<String>(
        'spentFormatted', 
        WidgetDataProvider.formatCurrencyDollar(data['spent'])
      );
      await HomeWidget.saveWidgetData<String>(
        'budgetFormatted', 
        WidgetDataProvider.formatCurrencyDollar(data['budget'])
      );
      await HomeWidget.saveWidgetData<String>(
        'lastAmountFormatted', 
        '- ${WidgetDataProvider.formatCurrencyDollar(data['lastAmount'])}'
      );
      
      // Trigger widget update
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
        iOSName: _iOSWidgetName,
      );
      
      print('Widget updated successfully');
    } catch (e) {
      print('Error updating widget: $e');
    }
  }
  
  /// Initialize widget on app launch
  static Future<void> initialize() async {
    try {
      // Register click callbacks
      HomeWidget.setAppGroupId('group.com.undiyal');
      
      // Update widget with initial data
      await updateWidget();
      
      // Setup background work
      await _setupBackgroundWork();
      
      print('Widget initialized successfully');
    } catch (e) {
      print('Error initializing widget: $e');
    }
  }
  
  /// Setup periodic background updates
  static Future<void> _setupBackgroundWork() async {
    await Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: false,
    );
    
    // Register periodic task (every 1 hour)
    await Workmanager().registerPeriodicTask(
      'widget_update_periodic',
      'widgetUpdate',
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: true,
      ),
    );
  }
  
  /// Handle widget click actions
  static Future<void> registerCallbacks() async {
    // Handle FAB click - open to add expense screen
    HomeWidget.registerInteractivityCallback(
      _handleWidgetAction,
    );
  }
  
  /// Process widget click actions
  static Future<void> _handleWidgetAction(Uri? uri) async {
    if (uri != null) {
      final action = uri.host;
      
      switch (action) {
        case 'add_expense':
          // This will be handled by your app's navigation
          print('User clicked add expense from widget');
          break;
        case 'open_app':
          print('User clicked widget to open app');
          break;
        default:
          print('Unknown widget action: $action');
      }
    }
  }
}

/// Background callback for WorkManager
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'widgetUpdate') {
      await WidgetUpdater.updateWidget();
    }
    return Future.value(true);
  });
}
