import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';

class InfoModal {
  static void show(BuildContext context, String key) {
    final data = _modalContent[key];
    if (data == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppTheme.ivory,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580, maxHeight: 600),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data['title'] ?? '',
                          style: GoogleFonts.cinzel(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: AppTheme.ink,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.black12),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        data['body'] ?? '',
                        style: GoogleFonts.tenorSans(
                          fontSize: 14,
                          height: 1.8,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                          color: const Color(0xFF4A4A4A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static const Map<String, Map<String, String>> _modalContent = {
    'shipping': {
      'title': 'Shipping Information',
      'body':
          'We ship across India. Orders are processed within 1–2 business days.\n\n• Standard Delivery (5–7 days): ₹99 — Free on orders above ₹2,500\n• Express Delivery (2–3 days): ₹199\n\nYou will receive a tracking link via email and SMS once your order ships.',
    },
    'returns': {
      'title': 'Returns & Exchanges',
      'body':
          'We accept returns within 14 days of delivery for unworn, unwashed items with all tags intact.\n\nTo initiate a return, email us at returns@erish.in with your order number.\n\nExchanges are subject to stock availability. Refunds are processed within 5–7 business days after we receive the item.',
    },
    'faq': {
      'title': 'Frequently Asked Questions',
      'body':
          'How do I find my size?\nWe recommend going up a size if you prefer a relaxed fit. Our silhouettes are cut slim-to-true.\n\nAre the prints exactly as shown?\nWe photograph in natural light; colours may vary slightly across screens. The prints are as vivid in person.\n\nCan I cancel my order?\nCancellations are accepted within 2 hours of placing the order. After that, the order goes into processing.\n\nDo you ship internationally?\nInternational shipping is coming soon. Join our newsletter to be the first to know.',
    },
    'contact': {
      'title': 'Contact Us',
      'body':
          'We\'d love to hear from you.\n\n• Email: hello@erish.in\n• Instagram: @label_erish\n• Hours: Mon–Sat, 10am–6pm IST\n\nWe typically respond within 24 hours.',
    },
    'track': {
      'title': 'Track Your Order',
      'body':
          'Once your order ships, you will receive a tracking link via email and SMS.\n\nFor further help, email orders@erish.in with your order ID and we\'ll assist you right away.',
    },
    'privacy': {
      'title': 'Privacy Policy',
      'body':
          'ERISH collects minimal personal information (name, email, address) solely to process orders and communicate with you.\n\nWe do not sell or share your data with third parties. Payment information is processed securely via our payment gateway and is never stored on our servers.\n\nYou may request deletion of your data at any time by emailing privacy@erish.in.',
    },
    'terms': {
      'title': 'Terms & Conditions',
      'body':
          'By placing an order with ERISH you agree to our shipping and returns policies.\n\nAll product images, descriptions and content on this site are the intellectual property of ERISH and may not be reproduced without permission.\n\nPrices are in Indian Rupees (INR) and inclusive of applicable taxes.',
    },
  };
}
