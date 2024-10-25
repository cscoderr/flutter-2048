import 'package:flutter_2048/data/data.dart';

abstract class GameRepository {
  Future<void> createOrUpdate({
    required List<List<Tile?>> grids,
    required int currentScore,
    required int bestScore,
  });

  GameData? fetch();
}
