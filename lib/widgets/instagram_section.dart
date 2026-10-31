import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_theme.dart';

class InstagramSection extends StatelessWidget {
  const InstagramSection({super.key});

  static const String instagramUrl = 'https://www.instagram.com/label_erish/';

  Future<void> _launchInstagram() async {
    final uri = Uri.parse(instagramUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch Instagram: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;
    final crossAxisCount = screenWidth >= 1000
        ? 6
        : screenWidth >= 600
        ? 3
        : 2;

    // Use our beautiful campaign images for the instagram tiles
    final List<String> instaImages = [
      'assets/images/mood1.jpg',
      'assets/images/product1.jpg',
      'assets/images/banner1.jpg',
      'assets/images/mood2.jpg',
      'assets/images/product2.jpg',
      'assets/images/mood3.jpg',
    ];

    return Container(
      width: double.infinity,
      color: AppTheme.ivory,
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
                'INSTAGRAM',
                style: GoogleFonts.tenorSans(
                  color: AppTheme.pink,
                  fontSize: 11,
                  letterSpacing: 4.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A Little More ERISH',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  color: AppTheme.ink,
                  fontSize: isDesktop ? 36 : 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.tenorSans(
                    color: AppTheme.mutedText,
                    fontSize: 14.5,
                    height: 1.7,
                    fontWeight: FontWeight.w400,
                  ),
                  children: const [
                    TextSpan(
                      text:
                          'See the prints, the moments and the moods behind the collection. Follow along on Instagram ',
                    ),
                    TextSpan(
                      text: '@label_erish',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Grid of 6 square tiles
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: instaImages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  return _InstaTile(
                    imagePath: instaImages[index],
                    onTap: _launchInstagram,
                  );
                },
              ),
              const SizedBox(height: 48),

              // CTA button
              OutlinedButton(
                onPressed: _launchInstagram,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.ink,
                  side: const BorderSide(color: AppTheme.ink, width: 1.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text(
                  'FOLLOW ON INSTAGRAM',
                  style: GoogleFonts.tenorSans(
                    fontSize: 11,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w600,
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

class _InstaTile extends StatefulWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _InstaTile({required this.imagePath, required this.onTap});

  @override
  State<_InstaTile> createState() => _InstaTileState();
}

class _InstaTileState extends State<_InstaTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedScale(
                scale: _isHovered ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                child: Image.asset(widget.imagePath, fit: BoxFit.cover),
              ),

              // Hover overlay
              AnimatedOpacity(
                opacity: _isHovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.55),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '@label_erish',
                        style: GoogleFonts.tenorSans(
                          color: Colors.white,
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
