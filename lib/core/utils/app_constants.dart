import 'package:flutter_2048/data/data.dart';

class AppConstants {
  const AppConstants._();

  static const int maxGridSize = 4;
  static const int initialTiles = 2;
  static List<List<Tile?>> emptyGrid = List<List<Tile?>>.generate(
    maxGridSize,
    (i) => List<Tile?>.filled(maxGridSize, null),
  );
  static const String gameStorageKey = '__game_data__';
}
