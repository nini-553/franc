import 'dart:ui';
import 'package:flutter/cupertino.dart';
// Needed for Colors.white with opacity sometimes, though CupertinoColors works.

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.2, // Light translucency
    this.color,
    this.borderRadius,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    // Clamp opacity to valid range (0.0 to 1.0)
    final safeOpacity = opacity.clamp(0.0, 1.0);
    final safeBorderOpacity = 0.2.clamp(0.0, 1.0);
    
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (color ?? CupertinoColors.white).withOpacity(safeOpacity),
            borderRadius: borderRadius ?? BorderRadius.circular(24),
            border: Border.all(
              color: CupertinoColors.white.withOpacity(safeBorderOpacity),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
