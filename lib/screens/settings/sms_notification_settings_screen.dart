import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../services/sms_notification_listener.dart';

class SmsNotificationSettingsScreen extends StatefulWidget {
  const SmsNotificationSettingsScreen({super.key});

  @override
  State<SmsNotificationSettingsScreen> createState() => _SmsNotificationSettingsScreenState();
}

class _SmsNotificationSettingsScreenState extends State<SmsNotificationSettingsScreen> {
  bool _isEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    final enabled = await SmsNotificationListener.isListenerEnabled();
    setState(() {
      _isEnabled = enabled;
      _isLoading = false;
    });
  }

  Future<void> _toggleListener(bool enabled) async {
    setState(() {
      _isLoading = true;
    });

    final success = await SmsNotificationListener.setListenerEnabled(enabled);
    
    setState(() {
      _isEnabled = enabled;
      _isLoading = false;
    });

    if (success) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(enabled ? 'Listener Enabled' : 'Listener Disabled'),
          content: Text(
            enabled 
                ? 'SMS notification listener is now active. You will receive instant notifications for new transactions.'
                : 'SMS notification listener is disabled. App will need to scan SMS inbox manually.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _openSystemSettings() async {
    await SmsNotificationListener.openNotificationSettings();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('System Settings'),
        content: const Text(
          'To enable SMS notification listener, you need to:\n\n'
          '1. Go to Android Settings\n'
          '2. Apps → Special app access\n'
          '3. Find "Undiyal"\n'
          '4. Enable "Notification access"\n\n'
          'This allows the app to read SMS notifications in real-time.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Got it'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        middle: const Text('SMS Notifications'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey4.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Real-time SMS Detection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enable SMS notification listener to instantly detect new transactions without repeatedly scanning your inbox. This is more battery efficient.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Toggle Switch
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey4.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enable SMS Listener',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isEnabled 
                                ? 'Listener is active and monitoring SMS notifications'
                                : 'Listener is disabled',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    CupertinoSwitch(
                      value: _isEnabled,
                      onChanged: _isLoading ? null : _toggleListener,
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // System Settings Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey4.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  onPressed: _openSystemSettings,
                  child: const Row(
                    children: [
                      Icon(CupertinoIcons.settings, size: 20),
                      const SizedBox(width: 8),
                      const Text('Open System Settings'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Status Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isEnabled 
                      ? CupertinoColors.systemGreen.withOpacity(0.1)
                      : CupertinoColors.systemOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isEnabled 
                        ? CupertinoColors.systemGreen.withOpacity(0.3)
                        : CupertinoColors.systemOrange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isEnabled 
                              ? CupertinoIcons.check_mark_circled_solid
                              : CupertinoIcons.info,
                          size: 24,
                          color: _isEnabled 
                              ? CupertinoColors.systemGreen
                              : CupertinoColors.systemOrange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isEnabled 
                                ? 'SMS Notification Listener Active'
                                : 'SMS Notification Listener Inactive',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _isEnabled 
                                  ? CupertinoColors.systemGreen
                                  : CupertinoColors.systemOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEnabled 
                            ? 'The app will instantly detect new transactions when they arrive via SMS notifications.'
                            : 'The app will scan SMS inbox manually to detect transactions.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
