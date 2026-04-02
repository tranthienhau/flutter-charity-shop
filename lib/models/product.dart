class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currencyCode;
  final String imageUrl;
  final String category;
  final String handle;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.currencyCode = 'USD',
    required this.imageUrl,
    required this.category,
    required this.handle,
  });

  factory Product.fromShopifyNode(Map<String, dynamic> node) {
    final variant = (node['variants']['edges'] as List).firstOrNull;
    final image = (node['images']['edges'] as List).firstOrNull;

    return Product(
      id: node['id'] as String,
      title: node['title'] as String,
      description: node['description'] as String,
      price: double.tryParse(
              variant?['node']['priceV2']['amount']?.toString() ?? '0') ??
          0,
      currencyCode:
          variant?['node']['priceV2']['currencyCode'] as String? ?? 'USD',
      imageUrl: image?['node']['url'] as String? ??
          'https://picsum.photos/seed/fallback/400/400',
      category: node['productType'] as String? ?? 'General',
      handle: node['handle'] as String,
    );
  }
}
