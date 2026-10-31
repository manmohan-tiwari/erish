import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../motion/motion_tokens.dart';

enum ErishButtonVariant { primary, ghost, onDarkGhost }

/// ERISH Official Reusable Button
/// Incorporates editorial uppercase typography, responsive hover states, and reduced-motion safety.
class ErishButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ErishButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;

  const ErishButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ErishButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
  });

  const ErishButton.ghost({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  }) : variant = ErishButtonVariant.ghost;

  const ErishButton.onDarkGhost({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  }) : variant = ErishButtonVariant.onDarkGhost;

  @override
  State<ErishButton> createState() => _ErishButtonState();
}

class _ErishButtonState extends State<ErishButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = widget.variant == ErishButtonVariant.primary;
    final bool isOnDark = widget.variant == ErishButtonVariant.onDarkGhost;

    // Background color based on variant and hover state
    Color backgroundColor;
    Color foregroundColor;
    Border? border;

    if (isPrimary) {
      backgroundColor = _isHovered ? AppColors.charcoal : AppColors.espresso;
      foregroundColor = AppColors.warmIvory;
      border = null;
    } else if (isOnDark) {
      backgroundColor = _isHovered
          ? Colors.white.withValues(alpha: 0.18)
          : Colors.white.withValues(alpha: 0.08);
      foregroundColor = AppColors.warmIvory;
      border = Border.all(
        color: _isHovered
            ? AppColors.pink
            : Colors.white.withValues(alpha: 0.35),
        width: 1,
      );
    } else {
      // Ghost light
      backgroundColor = _isHovered ? AppColors.espresso : Colors.transparent;
      foregroundColor = _isHovered ? AppColors.warmIvory : AppColors.espresso;
      border = Border.all(
        color: _isHovered ? AppColors.espresso : AppColors.sandBorder,
        width: 1,
      );
    }

    final Duration duration = MotionTokens.safeDuration(
      context,
      MotionTokens.fast,
    );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 15, color: foregroundColor),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text.toUpperCase(),
            style: AppTypography.button(color: foregroundColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return MouseRegion(
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: duration,
          curve: MotionTokens.easeOut,
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: border,
            borderRadius: BorderRadius.zero,
          ),
          child: content,
        ),
      ),
    );
  }
}
