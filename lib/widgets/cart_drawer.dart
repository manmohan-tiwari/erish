import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/motion/motion_tokens.dart';
import '../core/widgets/erish_button.dart';
import '../core/widgets/erish_image.dart';
import '../services/cart_provider.dart';

/// ERISH Interactive Slide-Out Cart Drawer
/// Slide-in animation from the right with backdrop dimming, dynamic free shipping calculation bar,
/// per-item thumbnail and quantity stepper, and direct checkout navigation.
class CartDrawer extends StatelessWidget {
  const CartDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final isOpen = cart.isCartDrawerOpen;
        final screenWidth = MediaQuery.of(context).size.width;
        final drawerWidth = screenWidth.clamp(320.0, 440.0);
        final bool reduceMotion = MotionTokens.shouldReduceMotion(context);
        final Duration duration = MotionTokens.safeDuration(
          context,
          MotionTokens.normal,
        );

        return IgnorePointer(
          ignoring: !isOpen,
          child: CallbackShortcuts(
            bindings: <ShortcutActivator, VoidCallback>{
              const SingleActivator(LogicalKeyboardKey.escape): () {
                cart.closeCartDrawer();
              },
            },
            child: Focus(
              autofocus: isOpen,
              child: Stack(
                children: [
                  // 1. Dimmed Backdrop
                  GestureDetector(
                    onTap: () => cart.closeCartDrawer(),
                    child: AnimatedOpacity(
                      opacity: isOpen ? 1.0 : 0.0,
                      duration: reduceMotion ? Duration.zero : duration,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.50),
                      ),
                    ),
                  ),

                  // 2. Slide Drawer from Right
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedSlide(
                      offset: isOpen
                          ? Offset.zero
                          : const Offset(1.0, 0.0),
                      duration: reduceMotion ? Duration.zero : duration,
                      curve: MotionTokens.easeOut,
                      child: Container(
                      width: drawerWidth,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.warmIvory,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 24,
                            offset: Offset(-4, 0),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'YOUR BAG (${cart.itemCount})',
                                    style: AppTypography.button(
                                      color: AppColors.espresso,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 20,
                                      color: AppColors.espresso,
                                    ),
                                    tooltip: 'Close Bag',
                                    onPressed: () => cart.closeCartDrawer(),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(color: AppColors.sandBorder),

                            // Dynamic Free Shipping Indicator
                            _buildFreeShippingBar(context, cart),

                            // Items List or Empty State
                            Expanded(
                              child: cart.items.isEmpty
                                  ? _buildEmptyState(context, cart)
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(20),
                                      itemCount: cart.items.length,
                                      separatorBuilder: (_, index) =>
                                          const Divider(
                                            height: 24,
                                            color: AppColors.sandBorder,
                                          ),
                                      itemBuilder: (context, index) {
                                        final item = cart.items[index];
                                        return _buildCartItemTile(
                                          context,
                                          cart,
                                          item,
                                          index,
                                        );
                                      },
                                    ),
                            ),

                            // Cart Footer
                            if (cart.items.isNotEmpty) ...[
                              const Divider(color: AppColors.sandBorder),
                              _buildCartFooter(context, cart),
                            ],
                          ],
                        ),
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

  Widget _buildFreeShippingBar(BuildContext context, CartProvider cart) {
    final hasUnlocked = cart.hasFreeShipping;
    final remaining = cart.amountUntilFreeShipping;
    final progress = cart.freeShippingProgress;

    return Container(
      width: double.infinity,
      color: AppColors.paperWhite,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasUnlocked
                    ? Icons.local_shipping
                    : Icons.card_giftcard_outlined,
                size: 16,
                color: hasUnlocked ? AppColors.softOlive : AppColors.pink,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasUnlocked
                      ? '✦ You\'ve unlocked FREE standard shipping!'
                      : 'Add ₹$remaining more to unlock FREE shipping!',
                  style: AppTypography.caption(
                    color: hasUnlocked
                        ? AppColors.softOlive
                        : AppColors.espresso,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.sandBorder.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                hasUnlocked ? AppColors.softOlive : AppColors.pink,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemTile(
    BuildContext context,
    CartProvider cart,
    dynamic item,
    int index,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail Image
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: ErishImage(
            imagePath: item.product.image,
            width: 72,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 14),

        // Product details & Quantity Stepper
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.cardTitle(color: AppColors.espresso),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    color: AppColors.sandBorder.withValues(alpha: 0.4),
                    child: Text(
                      'SIZE: ${item.selectedSize}',
                      style: AppTypography.caption(
                        color: AppColors.espresso,
                      ).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item.product.priceFormatted,
                    style: AppTypography.price(color: AppColors.pink),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Quantity Stepper
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.sandBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28),
                          icon: const Icon(Icons.remove, size: 14),
                          onPressed: () =>
                              cart.updateQuantity(index, item.quantity - 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text(
                            '${item.quantity}',
                            style: AppTypography.button(
                              color: AppColors.espresso,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28),
                          icon: const Icon(Icons.add, size: 14),
                          onPressed: () =>
                              cart.updateQuantity(index, item.quantity + 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Remove item button
        IconButton(
          icon: const Icon(
            Icons.delete_outline,
            size: 18,
            color: AppColors.muted,
          ),
          tooltip: 'Remove',
          onPressed: () => cart.removeItem(index),
        ),
      ],
    );
  }

  Widget _buildCartFooter(BuildContext context, CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SUBTOTAL',
                style: AppTypography.button(color: AppColors.espresso),
              ),
              Text(
                cart.formattedTotal,
                style: AppTypography.price(
                  color: AppColors.pink,
                ).copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SHIPPING',
                style: AppTypography.caption(color: AppColors.muted),
              ),
              Text(
                cart.hasFreeShipping ? 'FREE' : 'Calculated at checkout',
                style: AppTypography.caption(
                  color: cart.hasFreeShipping
                      ? AppColors.softOlive
                      : AppColors.muted,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Proceed to Checkout Button
          SizedBox(
            width: double.infinity,
            child: ErishButton(
              text: 'Proceed to Checkout',
              onPressed: () {
                cart.closeCartDrawer();
                context.push('/checkout');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, CartProvider cart) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 44,
                color: AppColors.muted,
              ),
              const SizedBox(height: 14),
              Text(
                'Your bag is currently empty.',
                style: AppTypography.sectionTitle(
                  color: AppColors.espresso,
                ).copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore our latest Wanderlust edit and discover your new favorite silhouette.',
                textAlign: TextAlign.center,
                style: AppTypography.body(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              ErishButton.ghost(
                text: 'Explore Collection',
                onPressed: () {
                  cart.closeCartDrawer();
                  context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
