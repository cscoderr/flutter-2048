import 'package:collection/collection.dart';
import 'package:flutter_2048/core/core.dart';

extension MultiDimensionalListExtension<T> on List<List<T>> {
  List<List<T>> rotate(int numRotations) {
    assert(numRotations >= 0 && numRotations <= 3,
        'numRotations must be integer between 0 and 3');

    return map2D(
      (row, col, _) {
        final rotatedCell = getRotatedCellAt(row, col, numRotations);
        return this[rotatedCell.row][rotatedCell.col];
      },
    );
  }

  List<List<T>> map2D(T Function(int row, int col, T) transform) {
    return mapIndexed((row, rowTiles) => rowTiles
        .mapIndexed((col, element) => transform(row, col, element))
        .toList()).toList();
  }
}
