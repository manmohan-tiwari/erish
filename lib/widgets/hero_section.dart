import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/motion/motion_tokens.dart';
import '../core/widgets/erish_button.dart';

/// ERISH Cinematic Hero Section
/// Features full-bleed campaign photography, layered dual gradient overlays,
/// scale-settle image transition, staggered typography reveal ('riseUp'),
/// and accessible reduced-motion support.
class HeroSection extends StatefulWidget {
  final VoidCallback onShopCollection;
  final VoidCallback onExploreNewArrivals;

  const HeroSection({
    super.key,
    required this.onShopCollection,
    required this.onExploreNewArrivals,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Staggered Animations
  late Animation<double> _imageScaleAnimation;
  late Animation<double> _eyebrowFade;
  late Animation<Offset> _eyebrowSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _scriptFade;
  late Animation<Offset> _scriptSlide;
  late Animation<double> _bodyFade;
  late Animation<Offset> _bodySlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.cinematic,
    );

    // Image scale settles from 1.04 down to 1.0
    _imageScaleAnimation = Tween<double>(begin: 1.04, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Stagger 1: Eyebrow (0.0 to 0.45)
    _eyebrowFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _eyebrowSlide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
          ),
        );

    // Stagger 2: Title "DRESS LIKE" (0.15 to 0.65)
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.65, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.15, 0.65, curve: Curves.easeOutCubic),
          ),
        );

    // Stagger 3: Italic Script "you're elsewhere." (0.35 to 0.85)
    _scriptFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
    );
    _scriptSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    // Stagger 4: Subtitle & CTA buttons (0.50 to 1.0)
    _bodyFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.50, 1.0, curve: Curves.easeOut),
    );
    _bodySlide = Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.50, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;
    final isMobile = screenWidth < 600;
    final bool reduceMotion = MotionTokens.shouldReduceMotion(context);

    // If reduced motion is requested, immediately jump to completed state
    if (reduceMotion && _controller.status != AnimationStatus.completed) {
      _controller.value = 1.0;
    }

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: isDesktop ? screenHeight.clamp(680.0, 950.0) : 600.0,
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // 1. Full-bleed background image with scale settle transition
          Positioned.fill(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: reduceMotion ? 1.0 : _imageScaleAnimation.value,
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/images/hero-model.jpg',
                  fit: BoxFit.cover,
                  alignment: isDesktop
                      ? Alignment.centerRight
                      : Alignment.topCenter,
                ),
              ),
            ),
          ),

          // 2. Dual Gradient Overlays (Editorial Vignette)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.82),
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.35, 0.65, 0.85],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.70),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45],
                ),
              ),
            ),
          ),

          // 3. Staggered Hero Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 60.0 : 24.0,
              vertical: isDesktop ? 80.0 : 40.0,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stagger 1: Eyebrow
                    FadeTransition(
                      opacity: _eyebrowFade,
                      child: SlideTransition(
                        position: _eyebrowSlide,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 1.5,
                              color: AppColors.pink,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'NEW SEASON · THE WANDERLUST EDIT',
                              style: AppTypography.eyebrow(
                                color: AppColors.warmIvory,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stagger 2: Title "DRESS LIKE"
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Text(
                          'DRESS LIKE',
                          style: AppTypography.displayHero(
                            color: AppColors.warmIvory,
                            isMobile: isMobile,
                          ),
                        ),
                      ),
                    ),

                    // Stagger 3: Italic Script "you're elsewhere."
                    FadeTransition(
                      opacity: _scriptFade,
                      child: SlideTransition(
                        position: _scriptSlide,
                        child: Text(
                          "you're elsewhere.",
                          style: AppTypography.displayTagline(
                            color: AppColors.gold,
                            isMobile: isMobile,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Stagger 4: Subtitle & CTAs
                    FadeTransition(
                      opacity: _bodyFade,
                      child: SlideTransition(
                        position: _bodySlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Born from a love of colour and wanderlust, each ERISH piece is a small act of joy — a print that turns heads, a silhouette that moves with you, a dress that feels like a destination.',
                              style: AppTypography.body(
                                color: AppColors.lightMuted,
                                isMobile: isMobile,
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Action Buttons
                            Wrap(
                              spacing: 16,
                              runSpacing: 14,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                ErishButton(
                                  text: 'Shop the Collection',
                                  onPressed: widget.onShopCollection,
                                ),
                                ErishButton.onDarkGhost(
                                  text: 'Explore New Arrivals ↓',
                                  onPressed: widget.onExploreNewArrivals,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
