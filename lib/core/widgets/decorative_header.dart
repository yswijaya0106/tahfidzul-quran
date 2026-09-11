import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The attractive top banner used behind the transparent app bar: a deep
/// green gradient with a subtle gold geometric motif, extending under the
/// device status bar (pair with `extendBodyBehindAppBar: true`).
class DecorativeHeader extends StatelessWidget {
  final double height;
  final Widget child;

  const DecorativeHeader({
    super.key,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.deepGreenDark, AppColors.deepGreen],
              ),
            ),
          ),
          CustomPaint(painter: _GeometricPatternPainter(), size: Size.infinite),
          child,
        ],
      ),
    );
  }
}

/// Draws a faint eight-point star lattice reminiscent of Islamic geometric
/// motifs, using the gold accent at low opacity so text stays legible.
class _GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.goldLight.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final dotPaint = Paint()
      ..color = AppColors.goldLight.withValues(alpha: 0.22);

    const spacing = 46.0;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        _drawStar(canvas, Offset(x, y), 14, linePaint);
        canvas.drawCircle(Offset(x, y), 2, dotPaint);
      }
    }

    final circlePaint = Paint()
      ..color = AppColors.goldLight.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      70,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      100,
      circlePaint,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
