import 'package:flutter_2048/domain/domain.dart';

class GridTileMovement {
  const GridTileMovement(this.fromGridTile, this.toGridTile);

  final GridTile? fromGridTile;
  final GridTile toGridTile;

  static GridTileMovement add(GridTile gridTile) {
    return GridTileMovement(null, gridTile);
  }

  static GridTileMovement shift(GridTile fromGridTile, GridTile toGridTile) {
    return GridTileMovement(fromGridTile, toGridTile);
  }

  static GridTileMovement noop(GridTile gridTile) {
    return GridTileMovement(gridTile, gridTile);
  }
}
