import 'package:flutter_2048/data/data.dart';

class GameData {
  const GameData({
    this.currentScore = 0,
    this.bestScore = 0,
    this.grids,
  });
  final int currentScore;
  final int bestScore;
  final List<List<Tile?>>? grids;

  factory GameData.fromJson(Map<String, dynamic> json) => GameData(
      currentScore: json['current_score'] as int,
      bestScore: json['best_score'] as int,
      grids: json['grids'] != null
          ? (json['grids'] as List<dynamic>)
              .map((tiles) => (tiles as List<dynamic>)
                  .map((e) => e == null ? null : Tile.fromJson(e))
                  .toList())
              .toList()
          : null);

  Map<String, dynamic> toJson() => {
        'current_score': currentScore,
        'best_score': bestScore,
        if (grids != null)
          'grids': grids
              ?.map((tiles) => tiles.map((e) => e?.toJson()).toList())
              .toList()
      };
}
