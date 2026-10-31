import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/motion/motion_tokens.dart';
import '../features/auth/services/auth_service.dart';
import '../services/cart_provider.dart';

/// ERISH Sticky Navigation Header
/// Responsive navigation bar with brand mark, hover sweep links,
/// search/account triggers, and animated badge counter.
class NavHeader extends StatelessWidget {
  final VoidCallback onNewInTap;
  final VoidCallback onDressesTap;
  final VoidCallback onCollectionsTap;
  final VoidCallback onStoryTap;
  final VoidCallback onSearchTap;
  final VoidCallback onAccountTap;
  final VoidCallback onMenuTap;
  final VoidCallback? onLogoTap;

  const NavHeader({
    super.key,
    required this.onNewInTap,
    required this.onDressesTap,
    required this.onCollectionsTap,
    required this.onStoryTap,
    required this.onSearchTap,
    required this.onAccountTap,
    required this.onMenuTap,
    this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmIvory.withValues(alpha: 0.96),
        border: const Border(
          bottom: BorderSide(color: AppColors.sandBorder, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              GestureDetector(
                onTap: onLogoTap ?? onNewInTap,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Image.asset(
                    'assets/images/erish-logo.png',
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Text(
                      'ERISH',
                      style: AppTypography.cardTitle(color: AppColors.espresso),
                    ),
                  ),
                ),
              ),

              // Center links (Desktop only >= 960px)
              if (isDesktop)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavLink(title: 'NEW IN', onTap: onNewInTap),
                    const SizedBox(width: 28),
                    _NavLink(title: 'DRESSES', onTap: onDressesTap),
                    const SizedBox(width: 28),
                    _NavLink(title: 'COLLECTIONS', onTap: onCollectionsTap),
                    const SizedBox(width: 28),
                    _NavLink(title: 'OUR STORY', onTap: onStoryTap),
                  ],
                ),

              // Right Icons (Search, Account, Bag)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.espresso,
                    ),
                    tooltip: 'Search',
                    onPressed: onSearchTap,
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 4),
                    Consumer<AuthService>(
                      builder: (context, auth, _) {
                        return IconButton(
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                auth.isAuthenticated
                                    ? Icons.person
                                    : Icons.person_outline,
                                size: 20,
                                color: AppColors.espresso,
                              ),
                              if (auth.isAuthenticated)
                                Positioned(
                                  right: -1,
                                  top: -1,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.pink,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          tooltip: auth.isAuthenticated
                              ? 'Account (${auth.displayName})'
                              : 'Sign In / Account',
                          onPressed: onAccountTap,
                        );
                      },
                    ),
                  ],
                  const SizedBox(width: 4),
                  Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      return InkWell(
                        onTap: () => cart.toggleCartDrawer(),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                size: 20,
                                color: AppColors.espresso,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'BAG',
                                style: AppTypography.button(
                                  color: AppColors.espresso,
                                ),
                              ),
                              const SizedBox(width: 6),
                              AnimatedSwitcher(
                                duration: MotionTokens.safeDuration(
                                  context,
                                  MotionTokens.fast,
                                ),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  key: ValueKey<int>(cart.itemCount),
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.pink,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${cart.itemCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (!isDesktop) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        size: 24,
                        color: AppColors.espresso,
                      ),
                      tooltip: 'Menu',
                      onPressed: onMenuTap,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _NavLink({required this.title, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: AppTypography.button(
                color: _isHovered ? AppColors.pink : AppColors.espresso,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: MotionTokens.safeDuration(context, MotionTokens.fast),
              curve: MotionTokens.easeOut,
              height: 1.5,
              width: _isHovered ? 28 : 0,
              color: AppColors.pink,
            ),
          ],
        ),
      ),
    );
  }
}
