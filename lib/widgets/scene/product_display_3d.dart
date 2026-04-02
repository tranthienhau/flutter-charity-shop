import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product.dart';
import '../../utils/format_currency.dart';

class ProductDisplay3D extends StatefulWidget {
  final Product product;
  final double x;
  final double y;
  final double z;
  final double rotationX;
  final double rotationY;
  final double zoom;
  final Size sceneSize;
  final VoidCallback onTap;

  const ProductDisplay3D({
    super.key,
    required this.product,
    required this.x,
    required this.y,
    required this.z,
    required this.rotationX,
    required this.rotationY,
    required this.zoom,
    required this.sceneSize,
    required this.onTap,
  });

  @override
  State<ProductDisplay3D> createState() => _ProductDisplay3DState();
}

class _ProductDisplay3DState extends State<ProductDisplay3D> {
  bool _hovered = false;

  Offset _project(double x, double y, double z) {
    final cx = widget.sceneSize.width / 2;
    final cy = widget.sceneSize.height / 2;
    final scale = widget.zoom *
        math.min(widget.sceneSize.width, widget.sceneSize.height) *
        0.35;
    const d = 2.5;

    final cosY = math.cos(widget.rotationY);
    final sinY = math.sin(widget.rotationY);
    final rx = x * cosY - z * sinY;
    final rz = x * sinY + z * cosY;

    final cosX = math.cos(widget.rotationX);
    final sinX = math.sin(widget.rotationX);
    final ry = y * cosX - rz * sinX;
    final rz2 = y * sinX + rz * cosX;

    final perspective = 5.0 / (5.0 + rz2 + d);
    return Offset(
      cx + rx * scale * perspective,
      cy + ry * scale * perspective,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pos = _project(widget.x, widget.y, widget.z);
    const d = 2.5;
    final rz = widget.x * math.sin(widget.rotationY) +
        widget.z * math.cos(widget.rotationY);
    final rz2 = widget.y * math.sin(widget.rotationX) +
        rz * math.cos(widget.rotationX);
    final perspective = 5.0 / (5.0 + rz2 + d);
    final cardScale = perspective * widget.zoom * 0.85;

    if (perspective < 0.1) return const SizedBox.shrink();

    final cardWidth = 90.0 * cardScale;
    final cardHeight = 120.0 * cardScale;

    return Positioned(
      left: pos.dx - cardWidth / 2,
      top: pos.dy - cardHeight,
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedScale(
            scale: _hovered ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4 * cardScale),
                      child: CachedNetworkImage(
                        imageUrl: widget.product.imageUrl,
                        fit: BoxFit.cover,
                        width: cardWidth,
                        placeholder: (_, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (_, url, err) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported, size: 20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2 * cardScale),
                  Text(
                    widget.product.title,
                    style: TextStyle(
                      fontSize: 8 * cardScale,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    formatCurrency(widget.product.price),
                    style: TextStyle(
                      fontSize: 9 * cardScale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D7D46),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
