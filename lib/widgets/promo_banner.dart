import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';

class PromoBanner extends StatelessWidget {
  final VoidCallback onExplore;

  const PromoBanner({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4332), Color(0xFF0F2B20)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: isDesktop ? 90.0 : 60.0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle typography watermark
          Opacity(
            opacity: 0.12,
            child: Text(
              'wear the feeling',
              maxLines: 1,
              style: GoogleFonts.cormorantInfant(
                color: Colors.white,
                fontSize: isDesktop ? 120 : 60,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // Foreground Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your next favourite is one scroll away.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: isDesktop ? 38 : 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'New prints. New season. Entirely, beautifully you.',
                textAlign: TextAlign.center,
                style: GoogleFonts.tenorSans(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onExplore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.pink,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'EXPLORE ERISH',
                  style: GoogleFonts.tenorSans(
                    fontSize: 11,
                    letterSpacing: 2.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
