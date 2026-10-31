import 'product_variant.dart';

/// ERISH Domain Product Model (Developer 2 Contract)
/// Prices are strictly stored as integer paise (1 INR = 100 paise) to prevent floating-point errors.
class ProductModel {
  final String id;
  final String slug;
  final String name;
  final String description;
  final String category;
  final int priceInPaise;
  final int? compareAtPriceInPaise;
  final List<String> images;
  final List<ProductVariant> variants;
  final String tag;
  final bool isActive;
  final String fabricCare;
  final String fitGuide;
  final String shippingInfo;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.category,
    required this.priceInPaise,
    this.compareAtPriceInPaise,
    required this.images,
    required this.variants,
    this.tag = 'New',
    this.isActive = true,
    this.fabricCare =
        '100% Breathable Viscose Crepe. Gentle hand wash or dry clean recommended.',
    this.fitGuide = 'Relaxed silhouette with subtle cinching. True to size.',
    this.shippingInfo =
        'Free express shipping across India on orders over ₹1,999.',
    required this.createdAt,
  });

  String get formattedPrice {
    final int rupees = priceInPaise ~/ 100;
    return '₹${rupees.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String? get formattedCompareAtPrice {
    if (compareAtPriceInPaise == null) return null;
    final int rupees = compareAtPriceInPaise! ~/ 100;
    return '₹${rupees.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  int get totalStock => variants.fold(0, (sum, v) => sum + v.stockQuantity);
  bool get inStock => totalStock > 0;
  List<String> get availableSizes =>
      variants.where((v) => v.isAvailable).map((v) => v.sizeLabel).toList();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'description': description,
      'category': category,
      'priceInPaise': priceInPaise,
      'compareAtPriceInPaise': compareAtPriceInPaise,
      'images': images,
      'variants': variants.map((v) => v.toMap()).toList(),
      'tag': tag,
      'isActive': isActive,
      'fabricCare': fabricCare,
      'fitGuide': fitGuide,
      'shippingInfo': shippingInfo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    final imagesList =
        (data['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        ['assets/images/product1.jpg'];

    final variantsList =
        (data['variants'] as List<dynamic>?)
            ?.map((e) => ProductVariant.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [
          ProductVariant(sku: '$id-S', sizeLabel: 'S', stockQuantity: 10),
          ProductVariant(sku: '$id-M', sizeLabel: 'M', stockQuantity: 10),
          ProductVariant(sku: '$id-L', sizeLabel: 'L', stockQuantity: 5),
        ];

    final createdStr = data['createdAt'] as String?;
    final createdAt = createdStr != null
        ? DateTime.tryParse(createdStr) ?? DateTime.now()
        : DateTime.now();

    return ProductModel(
      id: id,
      slug: data['slug'] ?? id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Maxi',
      priceInPaise: (data['priceInPaise'] as num?)?.toInt() ?? 279900,
      compareAtPriceInPaise: (data['compareAtPriceInPaise'] as num?)?.toInt(),
      images: imagesList,
      variants: variantsList,
      tag: data['tag'] ?? 'New',
      isActive: data['isActive'] ?? true,
      fabricCare:
          data['fabricCare'] ??
          '100% Breathable Viscose Crepe. Gentle hand wash or dry clean recommended.',
      fitGuide:
          data['fitGuide'] ??
          'Relaxed silhouette with subtle cinching. True to size.',
      shippingInfo:
          data['shippingInfo'] ??
          'Free express shipping across India on orders over ₹1,999.',
      createdAt: createdAt,
    );
  }

  static final List<ProductModel> seedProducts = [
    ProductModel(
      id: 'p1',
      slug: 'jaipur-paisley-maxi',
      name: 'Jaipur Paisley Maxi',
      description:
          'Flowing tiered silhouette with intricate Jaipur paisley motifs, deep V-neckline and breezy tiered skirt.',
      category: 'Maxi',
      priceInPaise: 279900, // ₹2,799
      compareAtPriceInPaise: 349900, // ₹3,499
      tag: 'New',
      images: [
        'assets/images/product1.jpg',
        'assets/images/banner1.jpg',
        'assets/images/hero-model.jpg',
      ],
      variants: const [
        ProductVariant(sku: 'ERISH-JPM-XS', sizeLabel: 'XS', stockQuantity: 8),
        ProductVariant(sku: 'ERISH-JPM-S', sizeLabel: 'S', stockQuantity: 15),
        ProductVariant(sku: 'ERISH-JPM-M', sizeLabel: 'M', stockQuantity: 12),
        ProductVariant(sku: 'ERISH-JPM-L', sizeLabel: 'L', stockQuantity: 6),
      ],
      fabricCare:
          '100% High-grade Viscose Silk Crepe. Dry clean only to preserve vibrant vegetable dyes.',
      fitGuide:
          'True to size. Relaxed tiered drape through the hips with fitted bodice.',
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p2',
      slug: 'azure-drift-kaftan',
      name: 'Azure Drift Kaftan',
      description:
          'Marbled turquoise and azure waves on sheer silk georgette with smocked waist and angel sleeves.',
      category: 'Kaftan',
      priceInPaise: 299900, // ₹2,999
      compareAtPriceInPaise: 389900,
      tag: 'Bestseller',
      images: [
        'assets/images/product2.jpg',
        'assets/images/mood1.jpg',
        'assets/images/banner2.jpg',
      ],
      variants: const [
        ProductVariant(sku: 'ERISH-ADK-S', sizeLabel: 'S', stockQuantity: 10),
        ProductVariant(sku: 'ERISH-ADK-M', sizeLabel: 'M', stockQuantity: 14),
        ProductVariant(sku: 'ERISH-ADK-L', sizeLabel: 'L', stockQuantity: 10),
        ProductVariant(sku: 'ERISH-ADK-XL', sizeLabel: 'XL', stockQuantity: 4),
      ],
      fabricCare:
          'Pure Chiffon Georgette. Cold hand wash with gentle detergent; air dry in shade.',
      fitGuide:
          'Comfortable oversized kaftan silhouette with elasticized internal waist tie.',
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p3',
      slug: 'carnival-ruffle-mini',
      name: 'Carnival Ruffle Mini',
      description:
          'Playful bohemian tunic mini dress with cascading flutter ruffle trim and vibrant jewel-toned print.',
      category: 'Mini',
      priceInPaise: 219900, // ₹2,199
      compareAtPriceInPaise: 289900,
      tag: 'New',
      images: [
        'assets/images/product3.jpg',
        'assets/images/mood2.jpg',
        'assets/images/product1.jpg',
      ],
      variants: const [
        ProductVariant(sku: 'ERISH-CRM-XS', sizeLabel: 'XS', stockQuantity: 5),
        ProductVariant(sku: 'ERISH-CRM-S', sizeLabel: 'S', stockQuantity: 8),
        ProductVariant(sku: 'ERISH-CRM-M', sizeLabel: 'M', stockQuantity: 7),
        ProductVariant(
          sku: 'ERISH-CRM-L',
          sizeLabel: 'L',
          stockQuantity: 0,
        ), // Out of stock
      ],
      fabricCare:
          '100% Mulmul Cotton with gold zari thread accents. Gentle machine wash cold.',
      fitGuide:
          'Mini length hitting mid-thigh. Flared silhouette with relaxed drop waist.',
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p4',
      slug: 'midnight-garden-midi',
      name: 'Midnight Garden Midi',
      description:
          'Botanical blooms scattered on ink black crepe with a flattering V-neck cut and comfortable A-line drape.',
      category: 'Holiday Edit',
      priceInPaise: 259900, // ₹2,599
      compareAtPriceInPaise: 329900,
      tag: 'New',
      images: [
        'assets/images/product4.jpg',
        'assets/images/mood3.jpg',
        'assets/images/banner1.jpg',
      ],
      variants: const [
        ProductVariant(sku: 'ERISH-MGM-S', sizeLabel: 'S', stockQuantity: 9),
        ProductVariant(sku: 'ERISH-MGM-M', sizeLabel: 'M', stockQuantity: 12),
        ProductVariant(sku: 'ERISH-MGM-L', sizeLabel: 'L', stockQuantity: 8),
      ],
      fabricCare:
          'Midnight Textured Poly-Crepe with smooth satin lining. Dry clean recommended.',
      fitGuide:
          'Tailored bodice with gentle A-line flare falling gracefully to mid-calf.',
      createdAt: DateTime.now(),
    ),
  ];
}
