import 'dart:convert';

import 'package:flutter_2048/core/core.dart';
import 'package:flutter_2048/data/data.dart';
import 'package:flutter_2048/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameRepositoryImpl implements GameRepository {
  const GameRepositoryImpl({required StorageService storageService})
      : _storageService = storageService;

  final StorageService _storageService;

  @override
  Future<void> createOrUpdate({
    required List<List<Tile?>> grids,
    required int currentScore,
    required int bestScore,
  }) async {
    final data = GameData(
      grids: grids,
      currentScore: currentScore,
      bestScore: bestScore,
    );
    await _storageService.save(
      AppConstants.gameStorageKey,
      jsonEncode(data.toJson()),
    );
  }

  @override
  GameData? fetch() {
    final response = _storageService.read(AppConstants.gameStorageKey);
    if (response == null) return null;
    final data = jsonDecode(response) as Map<String, dynamic>;
    return GameData.fromJson(data);
  }
}

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepositoryImpl(storageService: ref.read(storageServiceProvider)),
);
