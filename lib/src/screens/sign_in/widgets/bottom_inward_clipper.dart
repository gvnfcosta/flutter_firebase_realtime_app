// ===================== CLIPPER =====================

import 'package:flutter/material.dart';

class BottomInwardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final factor = size.width > 500 ? 2.0 : 1.7;
    final path = Path();

    final leftDepth = size.height * 0.78;
    final circleRadius = size.width * factor;
    final centerY = leftDepth + circleRadius * 0.92;
    final centerX = size.width * 0.85;
    final rightHeight = size.height * 0.2;

    path
      ..moveTo(0, 0)
      ..lineTo(0, leftDepth)
      ..arcTo(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: circleRadius),
        3.14159,
        3.14159,
        false,
      )
      ..lineTo(size.width, rightHeight)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
