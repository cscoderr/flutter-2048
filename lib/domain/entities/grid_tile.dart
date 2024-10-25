import 'package:flutter_2048/data/data.dart';
import 'package:flutter_2048/domain/domain.dart';

class GridTile {
  const GridTile(this.cell, this.tile);

  final Cell cell;
  final Tile tile;
}
