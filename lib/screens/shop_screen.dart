import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shop_provider.dart';
import '../widgets/scene/shop_scene_3d.dart';
import '../widgets/layout/shop_header.dart';
import '../widgets/layout/cart_drawer.dart';
import '../widgets/layout/product_detail_modal.dart';
import '../widgets/layout/loading_overlay.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      ref.read(selectedProductProvider.notifier).select(null);
      ref.read(isCartOpenProvider.notifier).close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        body: Stack(
          children: [
            // 3D scene
            const Positioned.fill(child: ShopScene3D()),

            // Header
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ShopHeader(),
            ),

            // Product detail modal
            const Positioned.fill(child: ProductDetailModal()),

            // Cart drawer
            const Positioned.fill(child: CartDrawer()),

            // Loading overlay
            const Positioned.fill(child: LoadingOverlay()),
          ],
        ),
      ),
    );
  }
}
