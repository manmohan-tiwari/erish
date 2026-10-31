class Product {
  final String id;
  final String name;
  final String priceFormatted;
  final int rawPrice;
  final String tag;
  final String image;
  final List<String> sizes;
  final String? description;
  final String category;
  final List<String> gallery;
  final String fabricCare;
  final String fitGuide;
  final String shippingInfo;

  const Product({
    required this.id,
    required this.name,
    required this.priceFormatted,
    required this.rawPrice,
    required this.tag,
    required this.image,
    required this.sizes,
    this.description,
    this.category = 'Maxi',
    this.gallery = const [],
    this.fabricCare =
        '100% Breathable Viscose Crepe. Gentle hand wash or dry clean recommended.',
    this.fitGuide =
        'Relaxed silhouette with subtle cinching. Model is 5\'8" wearing size S.',
    this.shippingInfo =
        'Free express shipping across India on orders over ₹2,500. Dispatched in 24–48 hours.',
  });

  String get slug => name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

  List<String> get allImages => gallery.isNotEmpty ? gallery : [image];

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    final String image =
        (data['image'] as String?) ?? 'assets/images/product1.jpg';
    final galleryData = data['gallery'] as List<dynamic>?;
    final List<String> gallery = galleryData != null
        ? galleryData.map((e) => e.toString()).toList()
        : <String>[image];

    return Product(
      id: id,
      name: data['name'] ?? '',
      priceFormatted: data['priceFormatted'] ?? '₹${data['rawPrice'] ?? 0}',
      rawPrice: (data['rawPrice'] as num?)?.toInt() ?? 0,
      tag: data['tag'] ?? 'New',
      image: image,
      sizes: List<String>.from(data['sizes'] ?? ['XS', 'S', 'M', 'L']),
      description: data['description'],
      category: data['category'] ?? 'Maxi',
      gallery: gallery,
      fabricCare:
          data['fabricCare'] ??
          '100% Breathable Viscose Crepe. Gentle hand wash or dry clean recommended.',
      fitGuide:
          data['fitGuide'] ??
          'Relaxed silhouette with subtle cinching. Model is 5\'8" wearing size S.',
      shippingInfo:
          data['shippingInfo'] ??
          'Free express shipping across India on orders over ₹2,500. Dispatched in 24–48 hours.',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'priceFormatted': priceFormatted,
      'rawPrice': rawPrice,
      'tag': tag,
      'image': image,
      'sizes': sizes,
      'description': description,
      'category': category,
      'gallery': allImages,
      'fabricCare': fabricCare,
      'fitGuide': fitGuide,
      'shippingInfo': shippingInfo,
    };
  }

  static const List<Product> initialProducts = [
    Product(
      id: 'p1',
      name: 'Jaipur Paisley Maxi',
      priceFormatted: '₹2,799',
      rawPrice: 2799,
      tag: 'New',
      image: 'assets/images/product1.jpg',
      category: 'Maxi',
      gallery: [
        'assets/images/product1.jpg',
        'assets/images/banner1.jpg',
        'assets/images/hero-model.jpg',
      ],
      sizes: ['XS', 'S', 'M', 'L'],
      description:
          'Flowing tiered silhouette with intricate Jaipur paisley motifs, deep V-neckline and breezy tiered skirt.',
      fabricCare:
          '100% High-grade Viscose Silk Crepe. Dry clean only to preserve vibrant vegetable dyes.',
      fitGuide:
          'True to size. Relaxed tiered drape through the hips with fitted bodice.',
    ),
    Product(
      id: 'p2',
      name: 'Azure Drift Kaftan',
      priceFormatted: '₹2,999',
      rawPrice: 2999,
      tag: 'Bestseller',
      image: 'assets/images/product2.jpg',
      category: 'Kaftan',
      gallery: [
        'assets/images/product2.jpg',
        'assets/images/mood1.jpg',
        'assets/images/banner2.jpg',
      ],
      sizes: ['S', 'M', 'L', 'XL'],
      description:
          'Marbled turquoise and azure waves on sheer silk georgette with smocked waist and angel sleeves.',
      fabricCare:
          'Pure Chiffon Georgette. Cold hand wash with gentle detergent; air dry in shade.',
      fitGuide:
          'Comfortable oversized kaftan silhouette with elasticized internal waist tie.',
    ),
    Product(
      id: 'p3',
      name: 'Carnival Ruffle Mini',
      priceFormatted: '₹2,199',
      rawPrice: 2199,
      tag: 'New',
      image: 'assets/images/product3.jpg',
      category: 'Mini',
      gallery: [
        'assets/images/product3.jpg',
        'assets/images/mood2.jpg',
        'assets/images/product1.jpg',
      ],
      sizes: ['XS', 'S', 'M', 'L'],
      description:
          'Playful bohemian tunic mini dress with cascading flutter ruffle trim and vibrant jewel-toned print.',
      fabricCare:
          '100% Mulmul Cotton with gold zari thread accents. Gentle machine wash cold.',
      fitGuide:
          'Mini length hitting mid-thigh. Flared silhouette with relaxed drop waist.',
    ),
    Product(
      id: 'p4',
      name: 'Midnight Garden Midi',
      priceFormatted: '₹2,599',
      rawPrice: 2599,
      tag: 'New',
      image: 'assets/images/product4.jpg',
      category: 'Holiday Edit',
      gallery: [
        'assets/images/product4.jpg',
        'assets/images/mood3.jpg',
        'assets/images/banner1.jpg',
      ],
      sizes: ['S', 'M', 'L'],
      description:
          'Botanical blooms scattered on ink black crepe with a flattering V-neck cut and comfortable A-line drape.',
      fabricCare:
          'Midnight Textured Poly-Crepe with smooth satin lining. Dry clean recommended.',
      fitGuide:
          'Tailored bodice with gentle A-line flare falling gracefully to mid-calf.',
    ),
  ];
}
