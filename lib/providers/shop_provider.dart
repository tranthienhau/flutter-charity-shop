import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/shopify_service.dart';

// Products
final shopifyServiceProvider = Provider((_) => ShopifyService());

final productsProvider = FutureProvider<List<Product>>((ref) {
  return ref.read(shopifyServiceProvider).fetchProducts();
});

// Selected product for modal
class SelectedProductNotifier extends Notifier<Product?> {
  @override
  Product? build() => null;

  void select(Product? product) => state = product;
}

final selectedProductProvider =
    NotifierProvider<SelectedProductNotifier, Product?>(
        SelectedProductNotifier.new);

// Cart open state
class CartOpenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void open() => state = true;
  void close() => state = false;
  void toggle() => state = !state;
}

final isCartOpenProvider =
    NotifierProvider<CartOpenNotifier, bool>(CartOpenNotifier.new);

// Cart
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void add(Product product) {
    final idx = state.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == idx)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i],
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  void remove(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
  }
}

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.total);
});

final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});
