import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/bank_call_rate_limiter.dart';

class BankBalanceSetupScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const BankBalanceSetupScreen({
    super.key,
    required this.onComplete,
    this.onSkip,
  });

  @override
  State<BankBalanceSetupScreen> createState() => _BankBalanceSetupScreenState();
}

class _BankBalanceSetupScreenState extends State<BankBalanceSetupScreen> {
  int? _selectedBankIndex;
  Map<String, int> _remainingCalls = {};

  @override
  void initState() {
    super.initState();
    _loadRemainingCalls();
  }

  Future<void> _loadRemainingCalls() async {
    final calls = <String, int>{};
    for (final bank in banks) {
      final remaining = await BankCallRateLimiter.getRemainingCalls(bank['code']!);
      calls[bank['code']!] = remaining;
    }
    if (mounted) {
      setState(() {
        _remainingCalls = calls;
      });
    }
  }

  final List<Map<String, String>> banks = const [
    {
      'name': 'SBI (State Bank of India)',
      'number': '09223866666',
      'code': 'SBI',
      'icon': '🏦',
    },
    {
      'name': 'Bank of Baroda',
      'number': '8468001111',
      'code': 'BOB',
      'icon': '🏛️',
    },
    {
      'name': 'IOB (Indian Overseas Bank)',
      'number': '9210622122',
      'code': 'IOB',
      'icon': '🏛️',
    },
    {
      'name': 'CUB (City Union Bank)',
      'number': '9278177444',
      'code': 'CUB',
      'icon': '🏛️',
    },
    {
      'name': 'HDFC Bank',
      'number': '18002703333',
      'code': 'HDFC',
      'icon': '🏛️',
    },
    {
      'name': 'Axis Bank',
      'number': '18004195959',
      'code': 'AXIS',
      'icon': '🏛️',
    },
  ];

  Future<void> _launchDialer(String number) async {
    final Uri telUri = Uri(scheme: 'tel', path: number);
    try {
      final launched = await launchUrl(
        telUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        await Clipboard.setData(ClipboardData(text: number));
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Dialer Not Available'),
              content: Text('Number $number copied to clipboard. Please dial manually.'),
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
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: number));
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Could not open dialer. Number $number copied to clipboard.'),
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
  }

  Future<void> _onCheckBalancePressed() async {
    if (_selectedBankIndex != null) {
      final bank = banks[_selectedBankIndex!];
      final bankCode = bank['code']!;
      
      // Check rate limit
      final canCall = await BankCallRateLimiter.canMakeCall(bankCode);
      if (!canCall) {
        final timeUntilReset = BankCallRateLimiter.getTimeUntilReset();
        final hours = timeUntilReset.inHours;
        final minutes = timeUntilReset.inMinutes % 60;
        
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Daily Limit Reached'),
              content: Text(
                'You have reached the maximum of ${BankCallRateLimiter.maxCallsPerDay} missed calls per day for ${bank['name']}.\n\n'
                'Please try again in ${hours}h ${minutes}m.',
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
        return;
      }
      
      // Record the call
      await BankCallRateLimiter.recordCall(bankCode);
      
      // Update remaining calls
      await _loadRemainingCalls();
      
      // Launch dialer
      _launchDialer(bank['number']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Set Up Bank Balance',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 8),
              Text(
                'Select your bank to check your balance via missed call',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.info_circle,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How it works',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Select your bank from the list\n'
                      '2. Tap "Check Balance" to open dialer\n'
                      '3. Make a missed call to the number\n'
                      '4. Receive SMS and app auto-updates your balance',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Select Your Bank',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: banks.length,
                  itemBuilder: (context, index) {
                    final bank = banks[index];
                    final isSelected = _selectedBankIndex == index;
                    final remainingCalls = _remainingCalls[bank['code']] ?? BankCallRateLimiter.maxCallsPerDay;
                    final isLimited = remainingCalls <= 0;
                    
                    return GestureDetector(
                      onTap: isLimited ? null : () {
                        setState(() {
                          _selectedBankIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.15)
                              : isLimited 
                                  ? AppColors.cardBackground.withOpacity(0.5)
                                  : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : isLimited ? AppColors.textSecondary.withOpacity(0.3) : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.2)
                                    : isLimited
                                        ? AppColors.textSecondary.withOpacity(0.1)
                                        : AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  bank['icon']!,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bank['name']!,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isLimited 
                                          ? AppColors.textSecondary 
                                          : isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Dial: ${bank['number']}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  if (isLimited)
                                    Text(
                                      'Daily limit reached',
                                      style: AppTextStyles.caption.copyWith(
                                        color: CupertinoColors.destructiveRed,
                                        fontSize: 12,
                                      ),
                                    )
                                  else if (remainingCalls < BankCallRateLimiter.maxCallsPerDay)
                                    Text(
                                      '$remainingCalls calls remaining today',
                                      style: AppTextStyles.caption.copyWith(
                                        color: remainingCalls == 1 
                                            ? CupertinoColors.activeOrange 
                                            : AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                CupertinoIcons.checkmark_circle_fill,
                                color: AppColors.primary,
                                size: 24,
                              )
                            else if (isLimited)
                              Icon(
                                CupertinoIcons.lock_fill,
                                color: AppColors.textSecondary,
                                size: 20,
                              )
                            else
                              const Icon(
                                CupertinoIcons.circle,
                                color: AppColors.border,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _selectedBankIndex != null ? _onCheckBalancePressed : null,
                  child: const Text('Check Balance'),
                ),
              ),
              const SizedBox(height: 12),
              // Show "Set up later" only during onboarding (when onSkip is provided)
              if (widget.onSkip != null)
                Center(
                  child: CupertinoButton(
                    onPressed: widget.onSkip,
                    child: Text(
                      'Set up later',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _selectedBankIndex != null
                      ? 'Tap "Check Balance" to open dialer'
                      : 'Select a bank to continue',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
