import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/shop_provider.dart';
import 'room_painter.dart';
import 'product_display_3d.dart';

class ShopScene3D extends ConsumerStatefulWidget {
  const ShopScene3D({super.key});

  @override
  ConsumerState<ShopScene3D> createState() => _ShopScene3DState();
}

class _ShopScene3DState extends ConsumerState<ShopScene3D> {
  double _rotX = -0.15;
  double _rotY = 0.0;
  double _zoom = 1.0;

  // Product shelf positions in 3D space (x, y, z)
  static const _shelfPositions = <List<double>>[
    // Left wall, bottom shelf
    [-2.9, 0.45, -1.8],
    [-2.9, 0.45, -0.8],
    // Left wall, top shelf
    [-2.9, -0.25, -1.8],
    [-2.9, -0.25, -0.8],
    // Right wall, bottom shelf
    [2.9, 0.45, -1.8],
    [2.9, 0.45, -0.8],
    // Right wall, top shelf
    [2.9, -0.25, -1.8],
    [2.9, -0.25, -0.8],
  ];

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _rotY += details.delta.dx * 0.005;
      _rotY = _rotY.clamp(-0.6, 0.6);
      _rotX += details.delta.dy * 0.003;
      _rotX = _rotX.clamp(-0.5, 0.15);
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount >= 2) {
      setState(() {
        _zoom = (_zoom * details.scale).clamp(0.6, 1.8);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final sceneSize = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanUpdate: _onPanUpdate,
          onScaleUpdate: _onScaleUpdate,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Room background
              CustomPaint(
                size: sceneSize,
                painter: RoomPainter(
                  rotationX: _rotX,
                  rotationY: _rotY,
                  zoom: _zoom,
                ),
              ),

              // Products on shelves
              ...productsAsync.when(
                data: (products) => _buildProductDisplays(
                  products,
                  sceneSize,
                ),
                loading: () => <Widget>[],
                error: (_, st) => <Widget>[],
              ),

              // Orbit hint
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _rotY == 0.0 ? 0.6 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Drag to orbit  |  Pinch to zoom',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildProductDisplays(
    List<Product> products,
    Size sceneSize,
  ) {
    // Depth-sort products so farther ones render behind
    final indexed = <({int idx, double depth})>[];
    for (var i = 0; i < math.min(products.length, _shelfPositions.length); i++) {
      final pos = _shelfPositions[i];
      final z = pos[0] * math.sin(_rotY) + pos[2] * math.cos(_rotY);
      indexed.add((idx: i, depth: z));
    }
    indexed.sort((a, b) => a.depth.compareTo(b.depth));

    return indexed.map((entry) {
      final i = entry.idx;
      final pos = _shelfPositions[i];
      return ProductDisplay3D(
        key: ValueKey(products[i].id),
        product: products[i],
        x: pos[0],
        y: pos[1],
        z: pos[2],
        rotationX: _rotX,
        rotationY: _rotY,
        zoom: _zoom,
        sceneSize: sceneSize,
        onTap: () {
          ref.read(selectedProductProvider.notifier).select(products[i]);
        },
      );
    }).toList();
  }
}
