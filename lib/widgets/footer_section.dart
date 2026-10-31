import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_theme.dart';
import 'info_modal.dart';

class FooterSection extends StatelessWidget {
  final VoidCallback onNewIn;
  final VoidCallback onDresses;
  final VoidCallback onCollections;
  final VoidCallback onStory;

  const FooterSection({
    super.key,
    required this.onNewIn,
    required this.onDresses,
    required this.onCollections,
    required this.onStory,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;

    return Container(
      width: double.infinity,
      color: AppTheme.ink,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60.0 : 24.0,
        vertical: 80.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildBrandCol()),
                        const SizedBox(width: 40),
                        Expanded(child: _buildExploreCol()),
                        Expanded(child: _buildHelpCol(context)),
                        Expanded(child: _buildAboutCol(context)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBrandCol(),
                        const SizedBox(height: 36),
                        _buildExploreCol(),
                        const SizedBox(height: 36),
                        _buildHelpCol(context),
                        const SizedBox(height: 36),
                        _buildAboutCol(context),
                      ],
                    ),
              const SizedBox(height: 60),
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '© ${DateTime.now().year} ERISH. All rights reserved. · ',
                    style: GoogleFonts.tenorSans(
                      color: const Color(0xFF8A837B),
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  InkWell(
                    onTap: () => launchUrl(
                      Uri.parse('https://www.instagram.com/label_erish/'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(
                      '@label_erish',
                      style: GoogleFonts.tenorSans(
                        color: AppTheme.pink,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                -1, 0, 0, 0, 255, // red
                0, -1, 0, 0, 255, // green
                0, 0, -1, 0, 255, // blue
                0, 0, 0, 1, 0, // alpha
              ]),
              child: Image.asset(
                'assets/images/erish-logo.png',
                height: 36,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Wear the feeling.',
              style: GoogleFonts.cormorantInfant(
                color: AppTheme.pink,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            'Expressive prints. Effortless silhouettes. Pieces that bring a little holiday into every day.',
            style: GoogleFonts.tenorSans(
              color: const Color(0xFFCFC8BF),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExploreCol() {
    return _FooterLinksGroup(
      title: 'EXPLORE',
      links: [
        _FooterLink(label: 'New Arrivals', onTap: onNewIn),
        _FooterLink(label: 'Dresses', onTap: onDresses),
        _FooterLink(label: 'All Collections', onTap: onCollections),
        _FooterLink(label: 'Our Story', onTap: onStory),
      ],
    );
  }

  Widget _buildHelpCol(BuildContext context) {
    return _FooterLinksGroup(
      title: 'HELP & INFORMATION',
      links: [
        _FooterLink(
          label: 'Contact Us',
          onTap: () => InfoModal.show(context, 'contact'),
        ),
        _FooterLink(
          label: 'Shipping Information',
          onTap: () => InfoModal.show(context, 'shipping'),
        ),
        _FooterLink(
          label: 'Returns & Exchanges',
          onTap: () => InfoModal.show(context, 'returns'),
        ),
        _FooterLink(label: 'FAQs', onTap: () => InfoModal.show(context, 'faq')),
        _FooterLink(
          label: 'Track Your Order',
          onTap: () => InfoModal.show(context, 'track'),
        ),
      ],
    );
  }

  Widget _buildAboutCol(BuildContext context) {
    return _FooterLinksGroup(
      title: 'ABOUT',
      links: [
        _FooterLink(label: 'Our Story', onTap: onStory),
        _FooterLink(
          label: 'Privacy Policy',
          onTap: () => InfoModal.show(context, 'privacy'),
        ),
        _FooterLink(
          label: 'Terms & Conditions',
          onTap: () => InfoModal.show(context, 'terms'),
        ),
        _FooterLink(
          label: 'Instagram @label_erish',
          onTap: () => launchUrl(
            Uri.parse('https://www.instagram.com/label_erish/'),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ],
    );
  }
}

class _FooterLink {
  final String label;
  final VoidCallback onTap;
  const _FooterLink({required this.label, required this.onTap});
}

class _FooterLinksGroup extends StatelessWidget {
  final String title;
  final List<_FooterLink> links;

  const _FooterLinksGroup({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.tenorSans(
            color: Colors.white,
            fontSize: 11,
            letterSpacing: 2.6,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: InkWell(
              onTap: link.onTap,
              child: Text(
                link.label,
                style: GoogleFonts.tenorSans(
                  color: const Color(0xFFCFC8BF),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
