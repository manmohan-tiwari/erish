import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app/router.dart';
import 'constants/app_theme.dart';
import 'core/widgets/erish_button.dart';
import 'models/product.dart';
import 'services/cart_provider.dart';
import 'services/firebase_service.dart';

import 'widgets/announcement_bar.dart';
import 'widgets/nav_header.dart';
import 'widgets/hero_section.dart';
import 'widgets/diptych_banner.dart';
import 'widgets/product_grid.dart';
import 'widgets/editorial_experience.dart';
import 'widgets/mood_section.dart';
import 'widgets/story_section.dart';
import 'widgets/promo_banner.dart';
import 'widgets/instagram_section.dart';
import 'widgets/newsletter_section.dart';
import 'widgets/footer_section.dart';
import 'widgets/cart_drawer.dart';
import 'widgets/search_dialog.dart';
import 'widgets/info_modal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseService = FirebaseService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        Provider.value(value: firebaseService),
      ],
      child: const ErishApp(),
    ),
  );

  // Initialize Firebase asynchronously in background with fallback
  // Ensures UI renders immediately with zero blocking white screen
  firebaseService.initialize();
}

class ErishApp extends StatelessWidget {
  const ErishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ERISH — Wear the Feeling',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: AppRouter.router,
    );
  }
}

class ErishHomePage extends StatefulWidget {
  final String? initialCategory;
  final bool openCartOnLoad;

  const ErishHomePage({
    super.key,
    this.initialCategory,
    this.openCartOnLoad = false,
  });

  @override
  State<ErishHomePage> createState() => _ErishHomePageState();
}

class _ErishHomePageState extends State<ErishHomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey _diptychKey = GlobalKey();
  final GlobalKey _productGridKey = GlobalKey();
  final GlobalKey _moodsKey = GlobalKey();
  final GlobalKey _storyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.openCartOnLoad) {
        Provider.of<CartProvider>(context, listen: false).openCartDrawer();
      } else if (widget.initialCategory != null &&
          widget.initialCategory != 'all') {
        _scrollToKey(_productGridKey);
      }
    });
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _showAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.warmIvory,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_pin, size: 48, color: AppColors.pink),
                  const SizedBox(height: 16),
                  Text(
                    'My Account & Orders',
                    style: AppTypography.sectionTitle(
                      color: AppColors.espresso,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Track shipments, review your order history, or access the store operations portal.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(color: AppColors.muted),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ErishButton(
                      text: 'Track Your Order',
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        InfoModal.show(context, 'track');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'CLOSE',
                      style: AppTypography.button(color: AppColors.muted),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );

    return Scaffold(
      key: _scaffoldKey,
      // Mobile Drawer (< 960px)
      endDrawer: Drawer(
        backgroundColor: AppColors.warmIvory,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/erish-logo.jpg', height: 32),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.espresso),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                _drawerItem('NEW IN', () {
                  Navigator.of(context).pop();
                  _scrollToKey(_productGridKey);
                }),
                _drawerItem('DRESSES', () {
                  Navigator.of(context).pop();
                  _scrollToKey(_diptychKey);
                }),
                _drawerItem('COLLECTIONS', () {
                  Navigator.of(context).pop();
                  _scrollToKey(_moodsKey);
                }),
                _drawerItem('OUR STORY', () {
                  Navigator.of(context).pop();
                  _scrollToKey(_storyKey);
                }),
                _drawerItem('SHOPPING BAG', () {
                  Navigator.of(context).pop();
                  Provider.of<CartProvider>(
                    context,
                    listen: false,
                  ).openCartDrawer();
                }),
                const Divider(color: AppColors.sandBorder, height: 32),
                _drawerItem('TRACK ORDER', () {
                  Navigator.of(context).pop();
                  InfoModal.show(context, 'track');
                }),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: firebaseService.getProductsStream(),
        initialData: Product.initialProducts,
        builder: (context, snapshot) {
          final products = snapshot.data ?? Product.initialProducts;

          return Stack(
            children: [
              // Main Scrollable Page
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 1. Announcement Bar
                  const SliverToBoxAdapter(child: AnnouncementBar()),

                  // 2. Sticky Nav Header
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    automaticallyImplyLeading: false,
                    toolbarHeight: 68,
                    backgroundColor: AppColors.warmIvory,
                    surfaceTintColor: Colors.transparent,
                    flexibleSpace: NavHeader(
                      onLogoTap: () {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                      onNewInTap: () => _scrollToKey(_productGridKey),
                      onDressesTap: () => _scrollToKey(_diptychKey),
                      onCollectionsTap: () => _scrollToKey(_moodsKey),
                      onStoryTap: () => _scrollToKey(_storyKey),
                      onSearchTap: () {
                        SearchDialog.show(context, products, (selectedProduct) {
                          context.push('/product/${selectedProduct.slug}');
                        });
                      },
                      onAccountTap: () => _showAccountDialog(context),
                      onMenuTap: () {
                        final scaffoldState = _scaffoldKey.currentState;
                        if (scaffoldState != null) {
                          scaffoldState.openEndDrawer();
                        }
                      },
                    ),
                  ),

                  // 3. Hero Section
                  SliverToBoxAdapter(
                    child: HeroSection(
                      onShopCollection: () => _scrollToKey(_productGridKey),
                      onExploreNewArrivals: () => _scrollToKey(_diptychKey),
                    ),
                  ),

                  // 4. Diptych Banner ("A World of Prints")
                  SliverToBoxAdapter(
                    key: _diptychKey,
                    child: DiptychBanner(
                      onTap: () => _scrollToKey(_productGridKey),
                    ),
                  ),

                  // 5. Product Grid ("New Arrivals / Just Landed")
                  SliverToBoxAdapter(
                    key: _productGridKey,
                    child: ProductGridSection(
                      products: products,
                      initialCategory: widget.initialCategory,
                    ),
                  ),

                  // 6. Editorial Experience ("The Wardrobe Experience")
                  SliverToBoxAdapter(
                    child: EditorialExperience(
                      onFindFavourite: () => _scrollToKey(_productGridKey),
                    ),
                  ),

                  // 7. Mood Section ("Shop by Mood")
                  SliverToBoxAdapter(
                    key: _moodsKey,
                    child: MoodSection(
                      onSelectMood: () => _scrollToKey(_productGridKey),
                    ),
                  ),

                  // 8. Story Section ("Born from wanderlust")
                  SliverToBoxAdapter(
                    key: _storyKey,
                    child: StorySection(
                      onDiscover: () => _scrollToKey(_productGridKey),
                    ),
                  ),

                  // 9. Promo Banner ("Your next favourite is one scroll away")
                  SliverToBoxAdapter(
                    child: PromoBanner(
                      onExplore: () => _scrollToKey(_productGridKey),
                    ),
                  ),

                  // 10. Instagram Section
                  const SliverToBoxAdapter(child: InstagramSection()),

                  // 11. Newsletter Section
                  const SliverToBoxAdapter(child: NewsletterSection()),

                  // 12. Footer Section
                  SliverToBoxAdapter(
                    child: FooterSection(
                      onNewIn: () => _scrollToKey(_productGridKey),
                      onDresses: () => _scrollToKey(_diptychKey),
                      onCollections: () => _scrollToKey(_moodsKey),
                      onStory: () => _scrollToKey(_storyKey),
                    ),
                  ),
                ],
              ),

              // Floating Cart Drawer Overlay
              const CartDrawer(),
            ],
          );
        },
      ),
    );
  }

  Widget _drawerItem(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: GoogleFonts.cinzel(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: AppColors.espresso,
          ),
        ),
      ),
    );
  }
}
