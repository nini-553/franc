import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../bank/bank_balance_setup_screen.dart';

/// Mandatory blocked Home state when availableBalance == null OR bankSetupCompleted == false.
/// User cannot access dashboard until setup complete. No back, no skip.
class BlockedHomeScreen extends StatelessWidget {
  final VoidCallback? onReturnFromSetup;

  const BlockedHomeScreen({super.key, this.onReturnFromSetup});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue #E3F2FD
      child: SafeArea(
        child: Column(
          children: [
            // Header: White circular icon near notifications area
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.money_dollar_circle_fill,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            // Centered content card
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title (bold, large)
                        const Text(
                          'Set up your bank balance',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Subtitle
                        const Text(
                          'Set up your bank balance so Undiyal knows how much you\'re really working with.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // Primary Button
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            onPressed: () async {
                              await Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => BankBalanceSetupScreen(
                                    onComplete: () => Navigator.of(context).pop(),
                                    onSkip: null,
                                  ),
                                ),
                              );
                              onReturnFromSetup?.call();
                            },
                            child: const Text(
                              'Set it up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
