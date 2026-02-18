import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_nameController.text.trim().isEmpty) {
      _showAlert('Please enter your name');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showAlert('Please enter your email');
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      _showAlert('Please enter your message');
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    // Show success dialog
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Thank You!'),
        content: const Text('Your feedback has been submitted successfully. We\'ll get back to you soon!'),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to profile
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Required'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
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
        border: null,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: AppColors.textPrimary),
        ),
        middle: const Text('Help & Support'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Header
            Text(
              'We\'d love to hear from you!',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            Text(
              'Share your feedback, suggestions, or report any issues.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 32),

            // Name Field
            _buildInputSection(
              title: 'Name',
              controller: _nameController,
              placeholder: 'Enter your name',
            ),

            const SizedBox(height: 20),

            // Email Field
            _buildInputSection(
              title: 'Email',
              controller: _emailController,
              placeholder: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            // Rating Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate your experience',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _rating = starIndex;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            starIndex <= _rating
                                ? CupertinoIcons.star_fill
                                : CupertinoIcons.star,
                            color: starIndex <= _rating
                                ? const Color(0xFFFFD700)
                                : const Color(0xFFE5E7EB),
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _getRatingText(_rating),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Message Field
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Message',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    controller: _messageController,
                    placeholder: 'Tell us about your experience, suggestions, or any issues...',
                    maxLines: 5,
                    style: AppTextStyles.body,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                onPressed: _isSubmitting ? null : _submitFeedback,
                child: _isSubmitting
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : Text(
                        'Submit Feedback',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Contact Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.mail,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Direct Contact',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For urgent matters, email us directly at:\nsupport@undiyal.com',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection({
    required String title,
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            keyboardType: keyboardType,
            style: AppTextStyles.body,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
          ),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Rate us';
    }
  }
}
