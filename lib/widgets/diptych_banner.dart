import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/motion/motion_tokens.dart';

/// ERISH Diptych Banner ("A World of Prints")
/// 2-panel editorial grid with hairline divider, smooth hover scale,
/// bottom gradient overlay, and responsive aspect ratio (1200:500 desktop, 4:3 mobile).
class DiptychBanner extends StatefulWidget {
  final VoidCallback onTap;

  const DiptychBanner({super.key, required this.onTap});

  @override
  State<DiptychBanner> createState() => _DiptychBannerState();
}

class _DiptychBannerState extends State<DiptychBanner> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;
    final isMobile = screenWidth < 600;
    final bool reduceMotion = MotionTokens.shouldReduceMotion(context);

    return Container(
      width: double.infinity,
      color: AppColors.cream,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60.0 : 20.0,
        vertical: 80.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              // Eyebrow
              Text(
                'FEATURED COLLECTION',
                style: AppTypography.eyebrow(color: AppColors.pink),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                'A World of Prints',
                textAlign: TextAlign.center,
                style: AppTypography.sectionTitle(
                  color: AppColors.espresso,
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(height: 14),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Text(
                  'Made for days that feel a little different. Statement prints, playful patterns and easy-to-wear silhouettes designed to bring colour to your wardrobe.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    color: AppColors.muted,
                    isMobile: isMobile,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Diptych Card
              MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: AspectRatio(
                      aspectRatio: isDesktop ? (1200 / 500) : (4 / 3),
                      child: Stack(
                        children: [
                          // Two Photos Diptych with smooth scale on hover
                          Positioned.fill(
                            child: AnimatedScale(
                              scale: (_isHovered && !reduceMotion) ? 1.04 : 1.0,
                              duration: MotionTokens.safeDuration(
                                context,
                                MotionTokens.slow,
                              ),
                              curve: MotionTokens.easeOut,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Image.asset(
                                      'assets/images/banner1.jpg',
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    color: AppColors.sandBorder,
                                  ),
                                  Expanded(
                                    child: Image.asset(
                                      'assets/images/banner2.jpg',
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Bottom Gradient Overlay for typography legibility
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.75),
                                    Colors.black.withValues(alpha: 0.35),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.45, 0.70],
                                ),
                              ),
                            ),
                          ),

                          // Overlay text
                          Positioned(
                            left: isDesktop ? 36 : 20,
                            bottom: isDesktop ? 36 : 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'The Holiday Edit',
                                  style: AppTypography.displayTagline(
                                    color: AppColors.warmIvory,
                                    isMobile: isMobile,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'EXPLORE THE COLLECTION',
                                      style: AppTypography.button(
                                        color: AppColors.warmIvory,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward,
                                      size: 14,
                                      color: AppColors.warmIvory,
                                    ),
                                  ],
                                ),
                              ],
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
      ),
    );
  }
}
