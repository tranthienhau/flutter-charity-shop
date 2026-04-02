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
  double _rotX = -0.05;
  double _rotY = 0.0;
  double _zoom = 1.0;

  // Product shelf positions on back wall (x, y, z)
  static const _shelfPositions = <List<double>>[
    // Bottom shelf - 4 products
    [-1.65, 0.1, -2.7],
    [-0.55, 0.1, -2.7],
    [0.55, 0.1, -2.7],
    [1.65, 0.1, -2.7],
    // Top shelf - 4 products
    [-1.65, -0.85, -2.7],
    [-0.55, -0.85, -2.7],
    [0.55, -0.85, -2.7],
    [1.65, -0.85, -2.7],
  ];

  double _prevScale = 1.0;

  void _onScaleStart(ScaleStartDetails details) {
    _prevScale = _zoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Single finger: orbit
      if (details.pointerCount == 1) {
        _rotY += details.focalPointDelta.dx * 0.005;
        _rotY = _rotY.clamp(-0.6, 0.6);
        _rotX += details.focalPointDelta.dy * 0.003;
        _rotX = _rotX.clamp(-0.5, 0.15);
      }
      // Two fingers: zoom
      if (details.pointerCount >= 2) {
        _zoom = (_prevScale * details.scale).clamp(0.6, 1.8);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final sceneSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Orbit/zoom gesture on the room background
            GestureDetector(
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              child: CustomPaint(
                size: sceneSize,
                painter: RoomPainter(
                  rotationX: _rotX,
                  rotationY: _rotY,
                  zoom: _zoom,
                ),
              ),
            ),

            // Products on shelves (above gesture layer so taps work)
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
              child: IgnorePointer(
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
            ),
          ],
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
