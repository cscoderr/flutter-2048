import 'package:flutter/material.dart';
import 'package:flutter_2048/core/core.dart';
import 'package:flutter_2048/data/data.dart';

class GridTileWidget extends StatelessWidget {
  const GridTileWidget({
    super.key,
    required this.gridTileMovement,
    required this.tileSize,
  });

  final GridTileMovement gridTileMovement;
  final double tileSize;

  @override
  Widget build(BuildContext context) {
    final tile = gridTileMovement.toGridTile.tile;

    final isDarkMode =
        Theme.of(context).colorScheme.brightness == Brightness.dark;
    return CustomAnimatedScale(
      duration: const Duration(milliseconds: 300),
      scale: gridTileMovement.fromGridTile == null ? 0 : 1,
      child: AnimatedContainer(
        height: tileSize,
        width: tileSize,
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: gridTileColor(tile.number, isDarkMode),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          tile.number.toString(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 24,
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}
