import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_2048/core/core.dart';
import 'package:flutter_2048/data/data.dart';
import 'package:flutter_2048/data/repositories/game_repository_impl.dart';
import 'package:flutter_2048/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameViewModel extends ChangeNotifier {
  GameViewModel({required GameRepository gameRepository})
      : _gameRepository = gameRepository;

  final GameRepository _gameRepository;

  final cells = <Cell>[];
  List<GridTileMovement> _gridTileMovements = <GridTileMovement>[];

  UnmodifiableListView<GridTileMovement> get gridTileMovements =>
      UnmodifiableListView(_gridTileMovements);

  List<List<Tile?>> _grids = AppConstants.emptyGrid;

  int _currentScore = 0;
  int get currentScore => _currentScore;
  set currentScore(int value) {
    _currentScore = value;
    notifyListeners();
  }

  int _bestScore = 0;
  int get bestScore => _bestScore;
  set bestScore(int value) {
    _bestScore = value;
    notifyListeners();
  }

  bool _isGameOver = false;
  bool get isGameOver => _isGameOver;
  set isGameOver(bool value) {
    _isGameOver = value;
    notifyListeners();
  }

  void initialize() {
    final gameData = _gameRepository.fetch();
    if (gameData == null) {
      startNewGame();
    } else {
      _bestScore = gameData.bestScore;
      notifyListeners();

      if (gameData.grids == null) {
        startNewGame();
      } else {
        _grids = gameData.grids!;
        _gridTileMovements = gameData.grids!
            .expandIndexed((row, tiles) => tiles.mapIndexed(
                  (col, tile) => tile == null
                      ? null
                      : GridTileMovement.noop(
                          GridTile(Cell(row, col), tile),
                        ),
                ))
            .whereNotNull()
            .toList();
        _currentScore = gameData.currentScore;
        _isGameOver = checkIfIsGameOver(_grids);
        notifyListeners();
      }
    }
  }

  Future<void> _saveGameData() async {
    await _gameRepository.createOrUpdate(
      grids: _grids,
      currentScore: _currentScore,
      bestScore: _bestScore,
    );
  }

  void startNewGame() {
    final availableCells = AppConstants.emptyGrid
        .expandIndexed((row, tiles) => List.generate(
              tiles.length,
              (col) => Cell(row, col),
            ))
        .toList()
      ..shuffle();
    final newGridTileMovements = <GridTileMovement>[];
    for (int i = 0; i < AppConstants.initialTiles; i++) {
      newGridTileMovements.add(
        GridTileMovement.add(availableCells[i].toInitialGridTile()),
      );
    }
    _gridTileMovements = newGridTileMovements;
    notifyListeners();

    final addedGridTiles = _gridTileMovements.map((e) => e.toGridTile).toList();

    _grids = AppConstants.emptyGrid.map2D((row, col, _) {
      return addedGridTiles
          .firstWhereOrNull(
              (element) => row == element.cell.row && col == element.cell.col)
          ?.tile;
    }).toList();
    currentScore = 0;
    _isGameOver = false;
    notifyListeners();
    _saveGameData();
  }

  void move(Direction direction) {
    var (updatedGrid, updatedGridTileMovements) = makeMove(_grids, direction);

    if (!hasGridChanged(updatedGridTileMovements)) {
      // No tiles were moved.
      return;
    }

    final scoreIncrement = updatedGridTileMovements
        .where((element) => element.fromGridTile == null)
        .toList()
        .sumOf((value) => value.toGridTile.tile.number);

    _currentScore += scoreIncrement;
    _bestScore = max(_bestScore, _currentScore);
    notifyListeners();

    final addedTileMovement = createRandomAddedTile(updatedGrid);
    if (addedTileMovement != null) {
      final gridTile = addedTileMovement.toGridTile;

      updatedGrid = updatedGrid.map2D(
        (row, column, tile) =>
            gridTile.cell.row == row && gridTile.cell.col == column
                ? gridTile.tile
                : tile,
      );
      updatedGridTileMovements.add(addedTileMovement);
      notifyListeners();
    }

    _grids = updatedGrid;
    _gridTileMovements = updatedGridTileMovements
      ..sort((a, _) => a.fromGridTile == null ? 1 : -1);
    _isGameOver = checkIfIsGameOver(_grids);
    notifyListeners();
    _saveGameData();
  }
}

final gameVMProvider = ChangeNotifierProvider<GameViewModel>((ref) {
  return GameViewModel(gameRepository: ref.read(gameRepositoryProvider));
});
