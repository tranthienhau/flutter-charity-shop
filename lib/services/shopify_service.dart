import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'mock_products.dart';

const _productsQuery = r'''
  query GetProducts($first: Int!) {
    products(first: $first) {
      edges {
        node {
          id
          title
          description
          handle
          productType
          images(first: 1) {
            edges {
              node {
                url
                altText
              }
            }
          }
          variants(first: 1) {
            edges {
              node {
                priceV2 {
                  amount
                  currencyCode
                }
              }
            }
          }
        }
      }
    }
  }
''';

class ShopifyService {
  final String? domain;
  final String? token;

  ShopifyService({this.domain, this.token});

  bool get _hasCredentials =>
      domain != null &&
      domain!.isNotEmpty &&
      token != null &&
      token!.isNotEmpty;

  Future<List<Product>> fetchProducts() async {
    if (!_hasCredentials) {
      return mockProducts;
    }

    try {
      final response = await http.post(
        Uri.parse('https://$domain/api/2024-01/graphql.json'),
        headers: {
          'X-Shopify-Storefront-Access-Token': token!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'query': _productsQuery,
          'variables': {'first': 8},
        }),
      );

      if (response.statusCode != 200) {
        return mockProducts;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final edges =
          data['data']['products']['edges'] as List<dynamic>;

      return edges
          .map((e) =>
              Product.fromShopifyNode(e['node'] as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return mockProducts;
    }
  }
}
