import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Terms & Conditions'),
        backgroundColor: AppColors.background,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms of Service',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to Undiyal. By using our app, you agree to these terms...',
                style: AppTextStyles.body,
              ),
              // Add more placeholder text as needed
            ],
          ),
        ),
      ),
    );
  }
}
