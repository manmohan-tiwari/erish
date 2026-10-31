import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/motion/motion_tokens.dart';
import '../models/mood_edit.dart';

/// ERISH Shop by Mood Section
/// 3:4 aspect-ratio editorial cards featuring:
/// The Getaway Edit, The Statement Edit, and The Everyday Escape.
/// Includes dark gradient overlays, subtle card lift and scale transitions.
class MoodSection extends StatelessWidget {
  final VoidCallback onSelectMood;

  const MoodSection({super.key, required this.onSelectMood});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      color: AppColors.warmIvory,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60.0 : 20.0,
        vertical: 80.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              Text(
                'SHOP BY MOOD',
                style: AppTypography.eyebrow(color: AppColors.pink),
              ),
              const SizedBox(height: 12),
              Text(
                'What\'s Your Mood?',
                textAlign: TextAlign.center,
                style: AppTypography.sectionTitle(
                  color: AppColors.espresso,
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(height: 48),

              // 3 cards
              if (isDesktop)
                Row(
                  children: MoodEdit.moods.map((mood) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: _MoodCard(mood: mood, onTap: onSelectMood),
                      ),
                    );
                  }).toList(),
                )
              else
                Column(
                  children: MoodEdit.moods.map((mood) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: _MoodCard(mood: mood, onTap: onSelectMood),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodCard extends StatefulWidget {
  final MoodEdit mood;
  final VoidCallback onTap;

  const _MoodCard({required this.mood, required this.onTap});

  @override
  State<_MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<_MoodCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MotionTokens.shouldReduceMotion(context);
    final duration = MotionTokens.safeDuration(context, MotionTokens.slow);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: duration,
          curve: MotionTokens.easeOut,
          transform: Matrix4.translationValues(
            0.0,
            (_isHovered && !reduceMotion) ? -6.0 : 0.0,
            0.0,
          ),
          decoration: BoxDecoration(
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.zero,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image with smooth scale
                  AnimatedScale(
                    scale: (_isHovered && !reduceMotion) ? 1.05 : 1.0,
                    duration: duration,
                    curve: MotionTokens.easeOut,
                    child: Image.asset(
                      widget.mood.image,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),

                  // Dark gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.88),
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 0.75],
                      ),
                    ),
                  ),

                  // Editorial Card Overlay Text
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mood.title,
                          style: AppTypography.displayTagline(
                            color: AppColors.warmIvory,
                          ).copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.mood.subtitle,
                          style: AppTypography.body(
                            color: const Color(0xFFEEEEEE),
                          ).copyWith(fontSize: 13, height: 1.5),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'EXPLORE EDIT',
                              style: AppTypography.button(
                                color: _isHovered
                                    ? AppColors.pink
                                    : AppColors.warmIvory,
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedSlide(
                              offset: (_isHovered && !reduceMotion)
                                  ? const Offset(0.3, 0)
                                  : Offset.zero,
                              duration: duration,
                              curve: MotionTokens.easeOut,
                              child: Icon(
                                Icons.arrow_forward,
                                size: 13,
                                color: _isHovered
                                    ? AppColors.pink
                                    : AppColors.warmIvory,
                              ),
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
    );
  }
}
