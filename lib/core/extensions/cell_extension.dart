import 'dart:math';

import 'package:flutter_2048/data/data.dart';

extension CellEx on Cell {
  GridTile toInitialGridTile() {
    return GridTile(
      this,
      Random().nextDouble() < 0.9 ? Tile(2) : Tile(4),
    );
  }
}
