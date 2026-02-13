import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/sms_expense_service.dart';

class SmsAnalysisLoadingScreen extends StatefulWidget {
  const SmsAnalysisLoadingScreen({super.key});

  @override
  State<SmsAnalysisLoadingScreen> createState() => _SmsAnalysisLoadingScreenState();
}

class _SmsAnalysisLoadingScreenState extends State<SmsAnalysisLoadingScreen> {
  String _statusMessage = 'Analyzing your SMS messages...';
  String _detailedStatus = '';

  @override
  void initState() {
    super.initState();
    _performAnalysis();
  }

  Future<void> _performAnalysis() async {
    try {
      setState(() {
        _statusMessage = 'Requesting SMS permissions...';
        _detailedStatus = 'Checking access to your message inbox';
      });

      // Check if SMS permission is granted
      final hasPermission = await SmsExpenseService.hasSmsPermission();
      if (!hasPermission) {
        setState(() {
          _statusMessage = 'SMS permission required';
          _detailedStatus = 'Please grant SMS access to analyze your transactions';
        });
        return;
      }

      setState(() {
        _statusMessage = 'Reading SMS messages...';
        _detailedStatus = 'Scanning your inbox for recent transactions';
      });

      // Perform comprehensive SMS analysis for current month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      final detectedTransactions = await SmsExpenseService.detectExpensesFromSms(
        since: Duration(days: now.difference(startOfMonth).inDays),
        limit: 500, // Read more messages for comprehensive analysis
      );

      setState(() {
        if (detectedTransactions.isNotEmpty) {
          _statusMessage = 'Analysis complete!';
          _detailedStatus = 'Found ${detectedTransactions.length} transactions from this month';
        } else {
          _statusMessage = 'Analysis complete';
          _detailedStatus = 'No recent transactions found in your SMS';
        }
      });

      // Wait a moment before auto-advancing
      await Future.delayed(const Duration(seconds: 2));

    } catch (e) {
      setState(() {
        _statusMessage = 'Analysis failed';
        _detailedStatus = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: Center(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.chat_bubble_text_fill,
                    size: 50,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Status Message
                Text(
                  _statusMessage,
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Detailed Status
                Text(
                  _detailedStatus,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Loading Indicator
                if (_statusMessage.contains('Analyzing') || 
                    _statusMessage.contains('Reading') || 
                    _statusMessage.contains('Requesting'))
                  const Column(
                    children: [
                      CupertinoActivityIndicator(
                        radius: 20,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'This may take a few moments...',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                
                // Success/Error State
                if (_statusMessage.contains('complete') || 
                    _statusMessage.contains('failed'))
                  Column(
                    children: [
                      Icon(
                        _statusMessage.contains('complete') 
                            ? CupertinoIcons.check_mark_circled_solid
                            : CupertinoIcons.clear_circled_solid,
                        size: 60,
                        color: _statusMessage.contains('complete') 
                            ? CupertinoColors.systemGreen
                            : CupertinoColors.systemRed,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _statusMessage.contains('complete') 
                            ? 'Setup will continue automatically'
                            : 'Please try again',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
