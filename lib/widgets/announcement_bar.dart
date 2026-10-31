import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class AnnouncementBar extends StatefulWidget {
  const AnnouncementBar({super.key});

  @override
  State<AnnouncementBar> createState() => _AnnouncementBarState();
}

class _AnnouncementBarState extends State<AnnouncementBar> {
  final List<String> _messages = [
    'Something rare just arrived. This is ERISH.',
    'Free shipping on orders above ₹2,500',
    'Hand-crafted prints. Wear the feeling.',
  ];
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.ink,
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.4),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Row(
            key: ValueKey<int>(_currentIndex),
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _messages[_currentIndex].toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.ivory,
                  fontSize: 11,
                  letterSpacing: 2.8,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '✦',
                style: TextStyle(color: AppTheme.pink, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
