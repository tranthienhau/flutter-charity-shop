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
    final cy = size.height / 2.2;
    final scale = zoom * math.min(size.width, size.height) * 0.4;

    const w = 2.5;
    const h = 1.8;
    const d = 3.0;

    Offset project(double x, double y, double z) {
      final cosY = math.cos(rotationY);
      final sinY = math.sin(rotationY);
      final rx = x * cosY - z * sinY;
      final rz = x * sinY + z * cosY;

      final cosX = math.cos(rotationX);
      final sinX = math.sin(rotationX);
      final ry = y * cosX - rz * sinX;
      final rz2 = y * sinX + rz * cosX;

      final perspective = 4.5 / (4.5 + rz2 + d);
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
          ..color = color.withAlpha(30)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }

    // Floor
    drawQuad(
      -w, h, -d, w, h, -d, w, h, d * 0.5, -w, h, d * 0.5,
      const Color(0xFFC4A882),
    );

    // Floor grid
    final gridPaint = Paint()
      ..color = const Color(0x12000000)
      ..strokeWidth = 0.5;
    for (var i = -2; i <= 2; i++) {
      canvas.drawLine(
        project(i.toDouble(), h, -d),
        project(i.toDouble(), h, d * 0.5),
        gridPaint,
      );
    }
    for (var i = -2; i <= 2; i++) {
      final zz = -d + i * 0.9;
      canvas.drawLine(project(-w, h, zz), project(w, h, zz), gridPaint);
    }

    // Back wall
    drawQuad(
      -w, -h, -d, w, -h, -d, w, h, -d, -w, h, -d,
      const Color(0xFFF5F0E8),
    );

    // Left wall
    drawQuad(
      -w, -h, -d, -w, -h, d * 0.5, -w, h, d * 0.5, -w, h, -d,
      const Color(0xFFEDE8DC),
    );

    // Right wall
    drawQuad(
      w, -h, -d, w, -h, d * 0.5, w, h, d * 0.5, w, h, -d,
      const Color(0xFFEDE8DC),
    );

    // Ceiling
    drawQuad(
      -w, -h, -d, w, -h, -d, w, -h, d * 0.5, -w, -h, d * 0.5,
      const Color(0xFFFAF8F4),
    );

    // Back wall shelves - 2 rows of 4 shelf segments
    const shelfThick = 0.05;
    const shelfDepth = 0.45;
    for (final sy in [0.15, -0.75]) {
      // Full shelf plank across back wall
      drawQuad(
        -w + 0.2, sy, -d + 0.01,
        w - 0.2, sy, -d + 0.01,
        w - 0.2, sy + shelfThick, -d + 0.01,
        -w + 0.2, sy + shelfThick, -d + 0.01,
        const Color(0xFF8B6914),
      );
      // Shelf top surface
      drawQuad(
        -w + 0.2, sy, -d + 0.01,
        w - 0.2, sy, -d + 0.01,
        w - 0.2, sy, -d + shelfDepth,
        -w + 0.2, sy, -d + shelfDepth,
        const Color(0xFFA07818),
      );
      // Shelf brackets
      for (final bx in [-1.8, -0.5, 0.5, 1.8]) {
        drawQuad(
          bx - 0.03, sy, -d + 0.01,
          bx + 0.03, sy, -d + 0.01,
          bx + 0.03, sy + 0.25, -d + 0.01,
          bx - 0.03, sy + 0.25, -d + 0.01,
          const Color(0xFF6B5010),
        );
      }
    }

    // Counter
    drawQuad(
      -0.7, 0.6, -0.2, 0.7, 0.6, -0.2, 0.7, h, -0.2, -0.7, h, -0.2,
      const Color(0xFFA07818),
    );
    drawQuad(
      -0.8, 0.6, -0.5, 0.8, 0.6, -0.5, 0.8, 0.6, 0.1, -0.8, 0.6, 0.1,
      const Color(0xFF8B6914),
    );

    // Sign on back wall
    final signPaint = Paint()..color = const Color(0xFF2D7D46);
    final p1 = project(-1.5, -h + 0.15, -d + 0.01);
    final p2 = project(1.5, -h + 0.15, -d + 0.01);
    final p3 = project(1.5, -h + 0.55, -d + 0.01);
    final p4 = project(-1.5, -h + 0.55, -d + 0.01);
    canvas.drawPath(
      Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..lineTo(p4.dx, p4.dy)
        ..close(),
      signPaint,
    );

    final signCenter = project(0, -h + 0.35, -d + 0.02);
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'CHARITY SHOP',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(signCenter.dx - textPainter.width / 2,
          signCenter.dy - textPainter.height / 2),
    );

    // Plants
    for (final px in [-2.0, 2.0]) {
      final potCenter = project(px, h - 0.18, 0.0);
      canvas.drawOval(
        Rect.fromCenter(center: potCenter, width: 18, height: 14),
        Paint()..color = const Color(0xFFC75B39),
      );
      final foliageCenter = project(px, h - 0.5, 0.0);
      canvas.drawCircle(
        foliageCenter,
        13,
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
