import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'review_receipt_screen.dart';

class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  State<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends State<ScanReceiptScreen> {
  bool _isScanning = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _startScanning() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        if (!mounted) return;
        
        // Navigate to review screen with image path
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => ReviewReceiptScreen(imagePath: photo.path),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error scanning receipt: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.textPrimary,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.textPrimary,
        border: null,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: AppColors.cardBackground),
        ),
        middle: const Text(
          'Scan Receipt',
          style: TextStyle(color: AppColors.cardBackground),
        ),
      ),
      child: Stack(
        children: [
          // Camera viewfinder simulation (since we can't embed real camera preview easily without camera package logic in build)
          // We will use a placeholder or black background until user taps 'scan' which opens system camera
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.textPrimary,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isScanning) ...[
                     // Scan guide overlay - full width/height
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final screenHeight = MediaQuery.of(context).size.height;
                        final guideWidth = screenWidth - 48;
                        final guideHeight = (screenHeight * 0.7).clamp(400.0, 600.0);
                        return Container(
                          width: guideWidth,
                          height: guideHeight,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                          // Corner indicators
                          Positioned(
                            top: -2,
                            left: -2,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: AppColors.primary, width: 4),
                                  left: BorderSide(color: AppColors.primary, width: 4),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: AppColors.primary, width: 4),
                                  right: BorderSide(color: AppColors.primary, width: 4),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            left: -2,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppColors.primary, width: 4),
                                  left: BorderSide(color: AppColors.primary, width: 4),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppColors.primary, width: 4),
                                  right: BorderSide(color: AppColors.primary, width: 4),
                                ),
                              ),
                            ),
                            ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Tap circle below to open camera',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textOnCard,
                      ),
                    ),
                  ] else ...[
                    // Scanning indicator
                    const CupertinoActivityIndicator(
                      radius: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Opening camera...',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textOnCard,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.xmark,
                        color: CupertinoColors.white,
                        size: 24,
                      ),
                    ),
                  ),
                   // Flash icon placeholder - functional in system camera
                   Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.light_max,
                      color: CupertinoColors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom capture button
          if (!_isScanning)
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _startScanning,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CupertinoColors.white,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: CupertinoColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.camera_fill,
                          color: AppColors.textPrimary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Instructions at bottom
          if (!_isScanning)
            Positioned(
              bottom: 160,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Scan physical receipts',
                      style: AppTextStyles.caption.copyWith(
                        color: CupertinoColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
