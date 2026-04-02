import 'dart:math' as math;
import 'package:flutter/material.dart';

class RoomPainter extends CustomPainter {
  final double rotationX;
  final double rotationY;
  final double zoom;

  RoomPainter({
    required this.rotationX,
    required this.rotationY,
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = zoom * math.min(size.width, size.height) * 0.35;

    // Room dimensions in local 3D coords
    const w = 3.0; // half-width
    const h = 1.5; // half-height
    const d = 2.5; // depth

    Offset project(double x, double y, double z) {
      // Rotate around Y
      final cosY = math.cos(rotationY);
      final sinY = math.sin(rotationY);
      final rx = x * cosY - z * sinY;
      final rz = x * sinY + z * cosY;

      // Rotate around X
      final cosX = math.cos(rotationX);
      final sinX = math.sin(rotationX);
      final ry = y * cosX - rz * sinX;
      final rz2 = y * sinX + rz * cosX;

      // Perspective projection
      final perspective = 5.0 / (5.0 + rz2 + d);
      return Offset(
        cx + rx * scale * perspective,
        cy + ry * scale * perspective,
      );
    }

    void drawQuad(
      double x1, double y1, double z1,
      double x2, double y2, double z2,
      double x3, double y3, double z3,
      double x4, double y4, double z4,
      Color color,
    ) {
      final path = Path()
        ..moveTo(project(x1, y1, z1).dx, project(x1, y1, z1).dy)
        ..lineTo(project(x2, y2, z2).dx, project(x2, y2, z2).dy)
        ..lineTo(project(x3, y3, z3).dx, project(x3, y3, z3).dy)
        ..lineTo(project(x4, y4, z4).dx, project(x4, y4, z4).dy)
        ..close();

      canvas.drawPath(path, Paint()..color = color);
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withAlpha(40)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }

    // Floor
    drawQuad(
      -w, h, -d,
      w, h, -d,
      w, h, d,
      -w, h, d,
      const Color(0xFFC4A882),
    );

    // Floor grid lines
    final gridPaint = Paint()
      ..color = const Color(0x15000000)
      ..strokeWidth = 0.5;
    for (var i = -2; i <= 2; i++) {
      final p1 = project(i.toDouble(), h, -d);
      final p2 = project(i.toDouble(), h, d);
      canvas.drawLine(p1, p2, gridPaint);
    }
    for (var i = -2; i <= 2; i++) {
      final p1 = project(-w, h, i.toDouble());
      final p2 = project(w, h, i.toDouble());
      canvas.drawLine(p1, p2, gridPaint);
    }

    // Back wall
    drawQuad(
      -w, -h, -d,
      w, -h, -d,
      w, h, -d,
      -w, h, -d,
      const Color(0xFFF5F0E8),
    );

    // Left wall
    drawQuad(
      -w, -h, -d,
      -w, -h, d * 0.6,
      -w, h, d * 0.6,
      -w, h, -d,
      const Color(0xFFEDE8DC),
    );

    // Right wall
    drawQuad(
      w, -h, -d,
      w, -h, d * 0.6,
      w, h, d * 0.6,
      w, h, -d,
      const Color(0xFFEDE8DC),
    );

    // Ceiling
    drawQuad(
      -w, -h, -d,
      w, -h, -d,
      w, -h, d * 0.6,
      -w, -h, d * 0.6,
      const Color(0xFFFAF8F4),
    );

    // Shelves (left wall)
    const shelfThick = 0.04;
    for (final sy in [-0.2, 0.5]) {
      drawQuad(
        -w + 0.01, sy, -d + 0.3,
        -w + 0.01, sy, -d + 2.2,
        -w + 0.01, sy + shelfThick, -d + 2.2,
        -w + 0.01, sy + shelfThick, -d + 0.3,
        const Color(0xFF8B6914),
      );
      // Shelf top surface
      drawQuad(
        -w + 0.01, sy, -d + 0.3,
        -w + 0.5, sy, -d + 0.3,
        -w + 0.5, sy, -d + 2.2,
        -w + 0.01, sy, -d + 2.2,
        const Color(0xFFA07818),
      );
    }

    // Shelves (right wall)
    for (final sy in [-0.2, 0.5]) {
      drawQuad(
        w - 0.01, sy, -d + 0.3,
        w - 0.01, sy, -d + 2.2,
        w - 0.01, sy + shelfThick, -d + 2.2,
        w - 0.01, sy + shelfThick, -d + 0.3,
        const Color(0xFF8B6914),
      );
      drawQuad(
        w - 0.01, sy, -d + 0.3,
        w - 0.5, sy, -d + 0.3,
        w - 0.5, sy, -d + 2.2,
        w - 0.01, sy, -d + 2.2,
        const Color(0xFFA07818),
      );
    }

    // Counter
    drawQuad(
      -0.8, 0.3, d * 0.3,
      0.8, 0.3, d * 0.3,
      0.8, h, d * 0.3,
      -0.8, h, d * 0.3,
      const Color(0xFFA07818),
    );
    // Counter top
    drawQuad(
      -0.9, 0.3, d * 0.15,
      0.9, 0.3, d * 0.15,
      0.9, 0.3, d * 0.45,
      -0.9, 0.3, d * 0.45,
      const Color(0xFF8B6914),
    );

    // Sign on back wall
    final signPaint = Paint()..color = const Color(0xFF2D7D46);
    final signPath = Path()
      ..moveTo(project(-1.5, -h + 0.2, -d + 0.01).dx,
          project(-1.5, -h + 0.2, -d + 0.01).dy)
      ..lineTo(project(1.5, -h + 0.2, -d + 0.01).dx,
          project(1.5, -h + 0.2, -d + 0.01).dy)
      ..lineTo(project(1.5, -h + 0.55, -d + 0.01).dx,
          project(1.5, -h + 0.55, -d + 0.01).dy)
      ..lineTo(project(-1.5, -h + 0.55, -d + 0.01).dx,
          project(-1.5, -h + 0.55, -d + 0.01).dy)
      ..close();
    canvas.drawPath(signPath, signPaint);

    // Sign text
    final signCenter = project(0, -h + 0.38, -d + 0.02);
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'CHARITY SHOP',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        signCenter.dx - textPainter.width / 2,
        signCenter.dy - textPainter.height / 2,
      ),
    );

    // Plants
    for (final px in [-2.5, 2.5]) {
      final potCenter = project(px, h - 0.15, d * 0.3);
      canvas.drawOval(
        Rect.fromCenter(center: potCenter, width: 20, height: 16),
        Paint()..color = const Color(0xFFC75B39),
      );
      final foliageCenter = project(px, h - 0.45, d * 0.3);
      canvas.drawCircle(
        foliageCenter,
        14,
        Paint()..color = const Color(0xFF3A8C3F),
      );
    }
  }

  @override
  bool shouldRepaint(RoomPainter oldDelegate) =>
      rotationX != oldDelegate.rotationX ||
      rotationY != oldDelegate.rotationY ||
      zoom != oldDelegate.zoom;
}
