import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// ERISH Universal Image Loader
/// Seamlessly loads either local assets or remote HTTP/Firebase Storage URLs
/// with graceful fallback error states to prevent application crashes.
class ErishImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;

  const ErishImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
  });

  bool get isNetwork =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (isNetwork) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.sandBorder.withValues(alpha: 0.2),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.pink,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.sandBorder.withValues(alpha: 0.35),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.muted,
          size: 28,
        ),
      ),
    );
  }
}

