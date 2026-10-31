import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';
import '../services/firebase_service.dart';

class NewsletterSection extends StatefulWidget {
  const NewsletterSection({super.key});

  @override
  State<NewsletterSection> createState() => _NewsletterSectionState();
}

class _NewsletterSectionState extends State<NewsletterSection> {
  final TextEditingController _controller = TextEditingController();
  String? _feedbackMessage;
  bool _isSuccess = false;
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    final email = _controller.text.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _feedbackMessage = 'Please enter a valid email address.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _feedbackMessage = null;
    });

    final success = await FirebaseService().subscribeNewsletter(email);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (success) {
          _feedbackMessage =
              'Welcome to ERISH ✦ A little colour is coming your way.';
          _isSuccess = true;
          _controller.clear();
        } else {
          _feedbackMessage = 'Something went wrong. Please try again.';
          _isSuccess = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    return Container(
      width: double.infinity,
      color: AppTheme.cream,
      padding: EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: isDesktop ? 90.0 : 60.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Column(
            children: [
              Text(
                'NEWSLETTER',
                style: GoogleFonts.tenorSans(
                  color: AppTheme.pink,
                  fontSize: 11,
                  letterSpacing: 4.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Let\'s Keep in Touch.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  color: AppTheme.ink,
                  fontSize: isDesktop ? 36 : 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'New collections, fresh inspiration and a little ERISH in your inbox.',
                textAlign: TextAlign.center,
                style: GoogleFonts.tenorSans(
                  color: AppTheme.mutedText,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 36),

              // Form
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppTheme.ink, width: 1.4),
                ),
                child: isDesktop
                    ? Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your email address',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: GoogleFonts.tenorSans(fontSize: 14),
                                onSubmitted: (_) => _handleSubmit(),
                              ),
                            ),
                          ),
                          _buildSubmitButton(),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: 'Enter your email address',
                                border: InputBorder.none,
                              ),
                              style: GoogleFonts.tenorSans(fontSize: 14),
                              onSubmitted: (_) => _handleSubmit(),
                            ),
                          ),
                          _buildSubmitButton(),
                        ],
                      ),
              ),

              // Feedback message
              if (_feedbackMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _feedbackMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tenorSans(
                    color: _isSuccess ? AppTheme.pink : Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
              const SizedBox(height: 16),

              Text(
                'By subscribing you agree to receive email updates from ERISH. Unsubscribe at any time.',
                textAlign: TextAlign.center,
                style: GoogleFonts.tenorSans(
                  color: AppTheme.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.ink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              'SIGN ME UP',
              style: GoogleFonts.tenorSans(
                fontSize: 11,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
