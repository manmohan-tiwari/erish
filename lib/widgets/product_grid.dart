import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/motion/motion_tokens.dart';
import '../core/widgets/erish_image.dart';
import '../models/product.dart';
import '../services/cart_provider.dart';

/// ERISH Product Catalog & Filter Grid
/// Responsive grid with:
/// - Breakpoints: 1-col (<600px), 2-col (600-1000px), 4-col (1000px+)
/// - Category quick filter bar: All Dresses, Maxi, Kaftan, Mini, Holiday Edit
/// - Interactive size matrix, quick add to bag, and navigation to PDP.
class ProductGridSection extends StatefulWidget {
  final List<Product> products;
  final String? initialCategory;

  const ProductGridSection({
    super.key,
    required this.products,
    this.initialCategory,
  });

  @override
  State<ProductGridSection> createState() => _ProductGridSectionState();
}

class _ProductGridSectionState extends State<ProductGridSection> {
  late String _activeCategory;

  final List<String> _categories = [
    'All Dresses',
    'Maxi',
    'Kaftan',
    'Mini',
    'Holiday Edit',
  ];

  @override
  void initState() {
    super.initState();
    _activeCategory =
        widget.initialCategory != null &&
            _categories.contains(widget.initialCategory)
        ? widget.initialCategory!
        : 'All Dresses';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;
    final isTablet = screenWidth >= 600 && screenWidth < 1000;
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);
    final isMobile = screenWidth < 600;

    // Filter products
    final filteredProducts = _activeCategory == 'All Dresses'
        ? widget.products
        : widget.products
              .where(
                (p) =>
                    p.category.toLowerCase() == _activeCategory.toLowerCase(),
              )
              .toList();

    return Container(
      width: double.infinity,
      color: AppColors.warmIvory,
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
                'NEW ARRIVALS',
                style: AppTypography.eyebrow(color: AppColors.pink),
              ),
              const SizedBox(height: 12),
              Text(
                'Just Landed',
                textAlign: TextAlign.center,
                style: AppTypography.sectionTitle(
                  color: AppColors.espresso,
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Text(
                  'Your next favourite, perhaps? Meet the latest pieces from ERISH — expressive prints and effortless styles made to stand out.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    color: AppColors.muted,
                    isMobile: isMobile,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Category Quick Filter Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _categories.map((cat) {
                    final isSelected = _activeCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _activeCategory = cat;
                          });
                        },
                        borderRadius: BorderRadius.zero,
                        child: AnimatedContainer(
                          duration: MotionTokens.safeDuration(
                            context,
                            MotionTokens.fast,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.espresso
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.espresso
                                  : AppColors.sandBorder,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            cat.toUpperCase(),
                            style: AppTypography.button(
                              color: isSelected
                                  ? AppColors.warmIvory
                                  : AppColors.espresso,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 48),

              // Product Grid
              if (filteredProducts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Text(
                    'No pieces found in this edit currently.',
                    style: AppTypography.body(color: AppColors.muted),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 32,
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (context, index) {
                    return _ProductCard(product: filteredProducts[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  String? _selectedSize;
  bool _isHovered = false;

  void _navigateToDetail() {
    context.push('/product/${widget.product.slug}');
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final bool reduceMotion = MotionTokens.shouldReduceMotion(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paperWhite,
          border: Border.all(
            color: _isHovered ? AppColors.pink : AppColors.sandBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Media with Hero Transition
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: _navigateToDetail,
                    child: ClipRect(
                      child: AnimatedScale(
                        scale: (_isHovered && !reduceMotion) ? 1.05 : 1.0,
                        duration: MotionTokens.safeDuration(
                          context,
                          MotionTokens.normal,
                        ),
                        curve: MotionTokens.easeOut,
                        child: Hero(
                          tag: 'product-image-${widget.product.id}',
                          child: ErishImage(
                            imagePath: widget.product.image,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tag Pill
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      color: AppColors.pink,
                      child: Text(
                        widget.product.tag.toUpperCase(),
                        style: AppTypography.button(
                          color: Colors.white,
                        ).copyWith(fontSize: 9, letterSpacing: 1.8),
                      ),
                    ),
                  ),

                  // Quick Add Bar (Slides up on hover)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedSlide(
                      offset: (_isHovered || reduceMotion)
                          ? Offset.zero
                          : const Offset(0, 1.0),
                      duration: MotionTokens.safeDuration(
                        context,
                        MotionTokens.fast,
                      ),
                      curve: MotionTokens.easeOut,
                      child: InkWell(
                        onTap: () {
                          final sizeToUse =
                              _selectedSize ?? widget.product.sizes.first;
                          cart.addItem(widget.product, sizeToUse);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${widget.product.name} ($sizeToUse) added to bag ✦',
                                style: AppTypography.button(
                                  color: AppColors.warmIvory,
                                ),
                              ),
                              backgroundColor: AppColors.espresso,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          color: AppColors.espresso,
                          alignment: Alignment.center,
                          child: Text(
                            'QUICK ADD TO BAG +',
                            style: AppTypography.button(
                              color: AppColors.warmIvory,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _navigateToDetail,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        widget.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.cardTitle(
                          color: AppColors.espresso,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.priceFormatted,
                    style: AppTypography.price(color: AppColors.pink),
                  ),
                  const SizedBox(height: 12),

                  // Size selection chips
                  Row(
                    children: widget.product.sizes.map((s) {
                      final isSelected = _selectedSize == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedSize = s;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.espresso
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.espresso
                                    : AppColors.sandBorder,
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? AppColors.warmIvory
                                    : AppColors.espresso,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
