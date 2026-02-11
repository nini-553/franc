import 'package:flutter/cupertino.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Help & Support'),
        backgroundColor: AppColors.background,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Us',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 16),
              Text(
                'If you have any questions or need assistance, please contact us at support@undiyal.com',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
