import 'package:flutter/material.dart';
import '../../assets/region_assets.dart';

class RegionStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color patternColor;

  const RegionStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.patternColor,
  });

  static RegionStyle forType(RegionVisualType type) {
    switch (type) {
      case RegionVisualType.bamboo:
        return const RegionStyle(
          backgroundColor: Color(0x3D4CAF50),
          borderColor: Color(0xFF2E7D32),
          patternColor: Color(0x4081C784),
        );
      case RegionVisualType.leaves:
        return const RegionStyle(
          backgroundColor: Color(0x3D8BC34A),
          borderColor: Color(0xFF558B2F),
          patternColor: Color(0x40AED581),
        );
      case RegionVisualType.stones:
        return const RegionStyle(
          backgroundColor: Color(0x3D78909C),
          borderColor: Color(0xFF37474F),
          patternColor: Color(0x40B0BEC5),
        );
      case RegionVisualType.flowers:
        return const RegionStyle(
          backgroundColor: Color(0x3DE91E63),
          borderColor: Color(0xFFC2185B),
          patternColor: Color(0x40F48FB1),
        );
      case RegionVisualType.wood:
        return const RegionStyle(
          backgroundColor: Color(0x3DFF9800),
          borderColor: Color(0xFFE65100),
          patternColor: Color(0x40FFB74D),
        );
      case RegionVisualType.water:
        return const RegionStyle(
          backgroundColor: Color(0x3D03A9F4),
          borderColor: Color(0xFF0277BD),
          patternColor: Color(0x404FC3F7),
        );
      case RegionVisualType.snow:
        return const RegionStyle(
          backgroundColor: Color(0x3DE0F7FA),
          borderColor: Color(0xFF00838F),
          patternColor: Color(0x4080DEEA),
        );
    }
  }
}

class RegionBorderPainter extends CustomPainter {
  final bool borderTop;
  final bool borderBottom;
  final bool borderLeft;
  final bool borderRight;
  final Color color;
  final double strokeWidth;

  RegionBorderPainter({
    required this.borderTop,
    required this.borderBottom,
    required this.borderLeft,
    required this.borderRight,
    required this.color,
    this.strokeWidth = 3.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final half = strokeWidth / 2;

    if (borderTop) {
      canvas.drawLine(Offset(0, half), Offset(size.width, half), paint);
    }
    if (borderBottom) {
      canvas.drawLine(Offset(0, size.height - half), Offset(size.width, size.height - half), paint);
    }
    if (borderLeft) {
      canvas.drawLine(Offset(half, 0), Offset(half, size.height), paint);
    }
    if (borderRight) {
      canvas.drawLine(Offset(size.width - half, 0), Offset(size.width - half, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant RegionBorderPainter oldDelegate) {
    return oldDelegate.borderTop != borderTop ||
        oldDelegate.borderBottom != borderBottom ||
        oldDelegate.borderLeft != borderLeft ||
        oldDelegate.borderRight != borderRight ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
