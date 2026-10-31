import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/motion/motion_tokens.dart';
import '../../../core/widgets/erish_button.dart';
import '../../../core/widgets/erish_image.dart';
import '../../../models/product.dart';
import '../../../services/cart_provider.dart';
import '../../../services/firebase_service.dart';
import '../../../widgets/cart_drawer.dart';

/// ERISH Official Product Detail Page (PDP)
/// Features:
/// - Hero image transition from catalog card
/// - Multi-image interactive gallery with desktop thumbnail strip & mobile swipe
/// - Size selector with visual state matrix
/// - Add to Bag with instant cart drawer integration
/// - Accordions for Fabric & Care, Fit Guide, and Shipping notes
class ProductDetailPage extends StatefulWidget {
  final String slug;

  const ProductDetailPage({super.key, required this.slug});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _activeImageIndex = 0;
  String? _selectedSize;
  int _quantity = 1;

  // Accordion expansion states
  bool _isFabricExpanded = true;
  bool _isFitExpanded = false;
  bool _isShippingExpanded = false;

  Product? _findProduct(List<Product> products) {
    try {
      return products.firstWhere(
        (p) => p.slug == widget.slug || p.id == widget.slug,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;
    final isMobile = screenWidth < 600;

    return StreamBuilder<List<Product>>(
      stream: firebaseService.getProductsStream(),
      initialData: Product.initialProducts,
      builder: (context, snapshot) {
        final products = snapshot.data ?? Product.initialProducts;
        final product = _findProduct(products);

        if (product == null) {
          return Scaffold(
            backgroundColor: AppColors.warmIvory,
            appBar: _buildAppBar(context, isDesktop),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PIECE NOT FOUND',
                      style: AppTypography.eyebrow(color: AppColors.pink),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'This silhouette is unavailable.',
                      textAlign: TextAlign.center,
                      style: AppTypography.sectionTitle(color: AppColors.espresso),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The piece you are looking for may have been archived or is temporarily out of catalog.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body(color: AppColors.muted),
                    ),
                    const SizedBox(height: 28),
                    ErishButton(
                      text: 'Return to Collection',
                      onPressed: () => context.go('/'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Pre-select first size if none chosen
        _selectedSize ??= product.sizes.isNotEmpty ? product.sizes.first : 'S';

        final images = product.allImages;

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          appBar: _buildAppBar(context, isDesktop),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Breadcrumb
                    _buildBreadcrumb(context, product),

                    // Main PDP Grid (2-column on desktop, 1-column on mobile)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 60.0 : 20.0,
                            vertical: 24.0,
                          ),
                          child: isDesktop
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left: Multi-Image Gallery
                                    Expanded(
                                      flex: 5,
                                      child: _buildGallery(
                                        product,
                                        images,
                                        isDesktop,
                                      ),
                                    ),
                                    const SizedBox(width: 56),

                                    // Right: Product Info & Actions
                                    Expanded(
                                      flex: 4,
                                      child: _buildProductDetails(
                                        product,
                                        isDesktop,
                                        isMobile,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildGallery(product, images, isDesktop),
                                    const SizedBox(height: 36),
                                    _buildProductDetails(
                                      product,
                                      isDesktop,
                                      isMobile,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),

              // Cart Drawer Overlay
              const CartDrawer(),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDesktop) {
    return AppBar(
      backgroundColor: AppColors.warmIvory,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.espresso),
        tooltip: 'Back to Home',
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
      ),
      title: GestureDetector(
        onTap: () => context.go('/'),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Image.asset(
            'assets/images/erish-logo.png',
            height: 34,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Text(
              'ERISH',
              style: AppTypography.cardTitle(color: AppColors.espresso),
            ),
          ),
        ),
      ),
      actions: [
        Consumer<CartProvider>(
          builder: (context, cart, _) {
            return InkWell(
              onTap: () => cart.toggleCartDrawer(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
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
                      style: AppTypography.button(color: AppColors.espresso),
                    ),
                    const SizedBox(width: 6),
                    Container(
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
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildBreadcrumb(BuildContext context, Product product) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              InkWell(
                onTap: () => context.go('/'),
                child: Text(
                  'HOME',
                  style: AppTypography.caption(color: AppColors.muted),
                ),
              ),
              const SizedBox(width: 8),
              const Text(' / ', style: TextStyle(color: AppColors.sandBorder)),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => context.go(
                  '/collections/${product.category.toLowerCase()}',
                ),
                child: Text(
                  product.category.toUpperCase(),
                  style: AppTypography.caption(color: AppColors.muted),
                ),
              ),
              const SizedBox(width: 8),
              const Text(' / ', style: TextStyle(color: AppColors.sandBorder)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  product.name.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(color: AppColors.espresso),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGallery(Product product, List<String> images, bool isDesktop) {
    final activeImage = images[_activeImageIndex.clamp(0, images.length - 1)];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Desktop Thumbnail Vertical Strip
        if (isDesktop && images.length > 1) ...[
          SizedBox(
            width: 76,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final isSelected = index == _activeImageIndex;
                return GestureDetector(
                  onTap: () => setState(() => _activeImageIndex = index),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: MotionTokens.safeDuration(
                        context,
                        MotionTokens.fast,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppColors.pink
                              : AppColors.sandBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: ErishImage(imagePath: images[index], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 18),
        ],

        // Main Large Hero Image
        Expanded(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.zero,
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Hero(
                    tag: 'product-image-${product.id}',
                    child: ErishImage(
                      imagePath: activeImage,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              // Mobile Gallery Horizontal Dots / Thumbnails
              if (!isDesktop && images.length > 1) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (idx) {
                    final isSelected = idx == _activeImageIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _activeImageIndex = idx),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSelected ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.pink
                              : AppColors.sandBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetails(Product product, bool isDesktop, bool isMobile) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          color: AppColors.pink,
          child: Text(
            product.tag.toUpperCase(),
            style: AppTypography.button(
              color: Colors.white,
            ).copyWith(fontSize: 10),
          ),
        ),
        const SizedBox(height: 14),

        // Product Title
        Text(
          product.name,
          style: AppTypography.sectionTitle(
            color: AppColors.espresso,
            isMobile: isMobile,
          ),
        ),
        const SizedBox(height: 8),

        // Price
        Row(
          children: [
            Text(
              product.priceFormatted,
              style: AppTypography.price(
                color: AppColors.pink,
              ).copyWith(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Inclusive of all taxes',
              style: AppTypography.caption(color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Description
        Text(
          product.description ??
              'Designed to bring effortless elegance to your closet with handcrafted details and radiant print work.',
          style: AppTypography.body(
            color: AppColors.espresso,
            isMobile: isMobile,
          ),
        ),
        const SizedBox(height: 28),

        const Divider(color: AppColors.sandBorder),
        const SizedBox(height: 20),

        // Size Selector Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SELECT SIZE',
              style: AppTypography.button(color: AppColors.espresso),
            ),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Size Guide: True to size. XS (32-34), S (34-36), M (36-38), L (38-40), XL (40-42).',
                      style: AppTypography.button(color: AppColors.warmIvory),
                    ),
                    backgroundColor: AppColors.espresso,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.straighten, size: 14, color: AppColors.pink),
                  const SizedBox(width: 4),
                  Text(
                    'SIZE GUIDE',
                    style: AppTypography.caption(color: AppColors.pink),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Size Buttons Matrix (XS, S, M, L, XL)
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ['XS', 'S', 'M', 'L', 'XL'].map((size) {
            final isAvailable = product.sizes.contains(size);
            final isSelected = _selectedSize == size;

            return InkWell(
              onTap: isAvailable
                  ? () => setState(() => _selectedSize = size)
                  : null,
              child: AnimatedContainer(
                duration: MotionTokens.safeDuration(context, MotionTokens.fast),
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.espresso
                      : (isAvailable
                            ? Colors.transparent
                            : AppColors.sandBorder.withValues(alpha: 0.3)),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.espresso
                        : (isAvailable
                              ? AppColors.sandBorder
                              : AppColors.sandBorder.withValues(alpha: 0.5)),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.warmIvory
                        : (isAvailable ? AppColors.espresso : AppColors.muted),
                    decoration: isAvailable
                        ? TextDecoration.none
                        : TextDecoration.lineThrough,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),

        // Quantity Stepper & Add to Bag
        Row(
          children: [
            // Quantity stepper
            Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.sandBorder),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text(
                    '$_quantity',
                    style: AppTypography.button(color: AppColors.espresso),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Add To Bag CTA
            Expanded(
              child: ErishButton(
                text: 'Add to Bag',
                onPressed: () {
                  final size = _selectedSize ?? 'S';
                  for (int i = 0; i < _quantity; i++) {
                    cart.addItem(product, size);
                  }
                  cart.openCartDrawer();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),

        const Divider(color: AppColors.sandBorder),
        const SizedBox(height: 12),

        // Accordion Sections (Fabric & Care, Fit Guide, Shipping)
        _buildAccordionTile(
          title: 'FABRIC & CARE',
          content: product.fabricCare,
          isExpanded: _isFabricExpanded,
          onTap: () => setState(() => _isFabricExpanded = !_isFabricExpanded),
        ),
        _buildAccordionTile(
          title: 'FIT & SILHOUETTE',
          content: product.fitGuide,
          isExpanded: _isFitExpanded,
          onTap: () => setState(() => _isFitExpanded = !_isFitExpanded),
        ),
        _buildAccordionTile(
          title: 'SHIPPING & RETURNS',
          content: product.shippingInfo,
          isExpanded: _isShippingExpanded,
          onTap: () =>
              setState(() => _isShippingExpanded = !_isShippingExpanded),
        ),
      ],
    );
  }

  Widget _buildAccordionTile({
    required String title,
    required String content,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.button(color: AppColors.espresso),
                ),
                Icon(
                  isExpanded ? Icons.remove : Icons.add,
                  size: 18,
                  color: AppColors.espresso,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                content,
                style: AppTypography.body(
                  color: AppColors.muted,
                ).copyWith(fontSize: 13),
              ),
            ),
          ),
        const Divider(color: AppColors.sandBorder),
      ],
    );
  }
}
