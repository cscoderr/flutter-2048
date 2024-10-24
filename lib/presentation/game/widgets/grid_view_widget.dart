import 'package:flutter/material.dart';

class GridViewWidget extends StatelessWidget {
  const GridViewWidget({
    super.key,
    required this.gridSize,
    required this.tileSize,
    required this.gridSpacing,
  });

  final int gridSize;
  final double tileSize;
  final double gridSpacing;

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).colorScheme.brightness == Brightness.dark;
    return CustomPaint(
      painter: GridPainter(
        gridSize: gridSize,
        tileSize: tileSize,
        gridSpacing: gridSpacing,
        color: Color(isDarkMode ? 0xff444444 : 0xffdddddd),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  GridPainter({
    required this.gridSize,
    required this.tileSize,
    required this.gridSpacing,
    required this.color,
    this.radius = 4.0,
  });
  final int gridSize;
  final double tileSize;
  final double gridSpacing;
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              col * (tileSize + gridSpacing),
              row * (tileSize + gridSpacing),
              tileSize,
              tileSize,
            ),
            Radius.circular(radius),
          ),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) =>
      oldDelegate.gridSize != gridSize ||
      oldDelegate.tileSize != tileSize ||
      oldDelegate.gridSpacing != gridSpacing ||
      oldDelegate.color != color ||
      oldDelegate.radius != radius;
}
