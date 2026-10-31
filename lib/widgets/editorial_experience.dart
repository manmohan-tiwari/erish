import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/motion/motion_tokens.dart';
import '../core/widgets/erish_button.dart';

/// ERISH Wardrobe Experience
/// Staggered editorial cards highlighting the 3 brand pillars:
/// 01 Expressive Prints, 02 Effortless Silhouettes, 03 Wear the Feeling.
/// Features hover translation, background illumination, and responsive editorial layout.
class EditorialExperience extends StatelessWidget {
  final VoidCallback onFindFavourite;

  const EditorialExperience({super.key, required this.onFindFavourite});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      color: AppColors.espresso,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60.0 : 24.0,
        vertical: 90.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildLeftColumn(isDesktop, isMobile)),
                    const SizedBox(width: 60),
                    Expanded(child: _buildRightCards()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeftColumn(isDesktop, isMobile),
                    const SizedBox(height: 48),
                    _buildRightCards(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn(bool isDesktop, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THE WARDROBE EXPERIENCE',
          style: AppTypography.eyebrow(color: AppColors.pink),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: AppTypography.sectionTitle(
              color: AppColors.warmIvory,
              isMobile: isMobile,
            ).copyWith(height: 1.1),
            children: [
              const TextSpan(text: 'Open your wardrobe to '),
              TextSpan(
                text: 'something new.',
                style: GoogleFonts.cormorantInfant(
                  color: AppColors.gold,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'A little bold. A little unexpected. Entirely your own. From slow mornings to sunset plans, find pieces that make getting dressed feel like the best part of your day.',
          style: AppTypography.body(
            color: AppColors.lightMuted,
            isMobile: isMobile,
          ),
        ),
        const SizedBox(height: 32),
        ErishButton(
          text: 'Find Your Next Favourite',
          onPressed: onFindFavourite,
        ),
      ],
    );
  }

  Widget _buildRightCards() {
    return Column(
      children: const [
        _EdCard(
          number: '01',
          title: 'EXPRESSIVE PRINTS',
          description: 'Patterns that bring colour to every single day.',
          delayIndex: 0,
        ),
        SizedBox(height: 16),
        _EdCard(
          number: '02',
          title: 'EFFORTLESS SILHOUETTES',
          description: 'Made to move with you, from morning to midnight.',
          delayIndex: 1,
        ),
        SizedBox(height: 16),
        _EdCard(
          number: '03',
          title: 'WEAR THE FEELING',
          description:
              'Because the best outfits create a feeling, not just a look.',
          delayIndex: 2,
        ),
      ],
    );
  }
}

class _EdCard extends StatefulWidget {
  final String number;
  final String title;
  final String description;
  final int delayIndex;

  const _EdCard({
    required this.number,
    required this.title,
    required this.description,
    required this.delayIndex,
  });

  @override
  State<_EdCard> createState() => _EdCardState();
}

class _EdCardState extends State<_EdCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MotionTokens.shouldReduceMotion(context);
    final duration = MotionTokens.safeDuration(context, MotionTokens.normal);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: duration,
        curve: MotionTokens.easeOut,
        transform: Matrix4.translationValues(
          (_isHovered && !reduceMotion) ? 8.0 : 0.0,
          0.0,
          0.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.pink.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: _isHovered
                ? AppColors.pink
                : Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              widget.number,
              style: AppTypography.displayTagline(
                color: _isHovered ? AppColors.warmIvory : AppColors.pink,
              ).copyWith(fontSize: 34),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: AppTypography.button(
                      color: AppColors.warmIvory,
                    ).copyWith(letterSpacing: 2.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.description,
                    style: AppTypography.body(
                      color: AppColors.lightMuted,
                    ).copyWith(fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: _isHovered ? 1.0 : 0.0,
              duration: duration,
              child: const Icon(
                Icons.arrow_forward,
                color: AppColors.pink,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
