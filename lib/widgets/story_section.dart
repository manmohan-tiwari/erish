import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';

class StorySection extends StatelessWidget {
  final VoidCallback onDiscover;

  const StorySection({super.key, required this.onDiscover});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;

    return Container(
      width: double.infinity,
      color: AppTheme.ivory,
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
                    Expanded(child: _buildArt()),
                    const SizedBox(width: 80),
                    Expanded(child: _buildStoryText(isDesktop)),
                  ],
                )
              : Column(
                  children: [
                    _buildArt(),
                    const SizedBox(height: 48),
                    _buildStoryText(isDesktop),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildArt() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Framed image
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: AppTheme.ink.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/erish-logo.png',
              width: 340,
              fit: BoxFit.contain,
            ),
          ),

          // Champagne Gold Ribbon treatment
          Positioned(
            top: -12,
            child: Transform.rotate(
              angle: -0.07,
              child: Container(
                width: 110,
                height: 28,
                color: AppTheme.gold.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryText(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BORN FROM WANDERLUST',
          style: GoogleFonts.tenorSans(
            color: AppTheme.pink,
            fontSize: 11,
            letterSpacing: 4.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: GoogleFonts.cinzel(
              color: AppTheme.ink,
              fontSize: isDesktop ? 38 : 28,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              height: 1.15,
            ),
            children: [
              const TextSpan(text: 'Every print holds a '),
              TextSpan(
                text: 'story.',
                style: GoogleFonts.cormorantInfant(
                  color: AppTheme.gold,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'ERISH was built on one belief — that getting dressed should feel like an adventure. Our prints are drawn from ancient bazaars, coastal mornings and moonlit terraces; translated into silhouettes that are effortless to wear and impossible to ignore.',
          style: GoogleFonts.tenorSans(
            color: const Color(0xFF4A4A4A),
            fontSize: 14.5,
            height: 1.85,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'We don\'t do quiet. We do colour, texture and the kind of confidence that makes a room turn around. Wear it your way, wherever the day takes you.',
          style: GoogleFonts.tenorSans(
            color: const Color(0xFF4A4A4A),
            fontSize: 14.5,
            height: 1.85,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '— Crafted with love, ERISH',
          style: GoogleFonts.cormorantInfant(
            color: AppTheme.gold,
            fontSize: 22,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: onDiscover,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.ink,
            side: const BorderSide(color: AppTheme.ink, width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: Text(
            'DISCOVER OUR COLLECTION',
            style: GoogleFonts.tenorSans(
              fontSize: 11,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
