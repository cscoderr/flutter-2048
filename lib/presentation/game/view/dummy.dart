import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide GridTile;
import 'package:flutter/services.dart';
import 'package:flutter_2048/core/core.dart';
import 'package:flutter_2048/data/data.dart';
import 'package:flutter_2048/presentation/game/game.dart';

const gridSize = 4;
const initialTiles = 2;
final emptyGrid = List<List<Tile?>>.generate(
    gridSize, (i) => List<Tile?>.filled(gridSize, null));

(List<List<Tile?>>, List<GridTileMovement>) makeMove(
    List<List<Tile?>> grid, Direction direction) {
  int numRotations;
  switch (direction) {
    case Direction.west:
      numRotations = 0;
      break;
    case Direction.south:
      numRotations = 1;
      break;
    case Direction.east:
      numRotations = 2;
      break;
    case Direction.north:
      numRotations = 3;
      break;
  }

  // Rotate the grid to process it as if the user swiped from right to left.
  var updatedGrid = grid.rotate(numRotations);
  var gridTileMovements = <GridTileMovement>[];

  updatedGrid =
      List<List<Tile?>>.generate(updatedGrid.length, (currentRowIndex) {
    var tiles = List<Tile?>.from(updatedGrid[currentRowIndex]);
    int? lastSeenTileIndex;
    int? lastSeenEmptyIndex;

    for (int currentColIndex = 0;
        currentColIndex < tiles.length;
        currentColIndex++) {
      var currentTile = tiles[currentColIndex];
      if (currentTile == null) {
        lastSeenEmptyIndex ??= currentColIndex;
        continue; // Move to the next iteration
      }

      var currentGridTile = GridTile(
          getRotatedCellAt(currentRowIndex, currentColIndex, numRotations),
          currentTile);

      if (lastSeenTileIndex == null) {
        if (lastSeenEmptyIndex == null) {
          gridTileMovements.add(GridTileMovement.noop(currentGridTile));
          lastSeenTileIndex = currentColIndex;
        } else {
          var targetCell = getRotatedCellAt(
              currentRowIndex, lastSeenEmptyIndex, numRotations);
          var targetGridTile = GridTile(targetCell, currentTile);
          gridTileMovements
              .add(GridTileMovement.shift(currentGridTile, targetGridTile));

          tiles[lastSeenEmptyIndex] = currentTile;
          tiles[currentColIndex] = null;
          lastSeenTileIndex = lastSeenEmptyIndex;
          lastSeenEmptyIndex++;
        }
      } else {
        if (tiles[lastSeenTileIndex]!.number == currentTile.number) {
          var targetCell = getRotatedCellAt(
              currentRowIndex, lastSeenTileIndex, numRotations);
          gridTileMovements.add(GridTileMovement.shift(
              currentGridTile, GridTile(targetCell, currentTile)));

          var addedTile = currentTile * 2;
          gridTileMovements
              .add(GridTileMovement.add(GridTile(targetCell, addedTile)));

          tiles[lastSeenTileIndex] = addedTile;
          tiles[currentColIndex] = null;
          lastSeenTileIndex = null;
          lastSeenEmptyIndex ??= currentColIndex;
        } else {
          if (lastSeenEmptyIndex == null) {
            gridTileMovements.add(GridTileMovement.noop(currentGridTile));
          } else {
            var targetCell = getRotatedCellAt(
                currentRowIndex, lastSeenEmptyIndex, numRotations);
            var targetGridTile = GridTile(targetCell, currentTile);
            gridTileMovements
                .add(GridTileMovement.shift(currentGridTile, targetGridTile));

            tiles[lastSeenEmptyIndex] = currentTile;
            tiles[currentColIndex] = null;
            lastSeenEmptyIndex++;
          }
          lastSeenTileIndex++;
        }
      }
    }
    return tiles;
  });

  // Rotate the grid back to its original state.
  updatedGrid =
      updatedGrid.rotate((-numRotations).floorMod(Direction.values.length));

  return (updatedGrid, gridTileMovements);
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final FocusNode _focusNode = FocusNode();
  int initialNum = 0;

  final gridSpacing = 4.0;
  final margin = 20;
  final cells = <Cell>[];

  List<GridTileMovement> gridTileMovements = <GridTileMovement>[];
  late List<List<Tile?>> grids;
  int currentScore = 0;
  int bestScore = 0;
  bool isGameOver = false;
  LogicalKeyboardKey? activeKeyDown;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    grids = emptyGrid;
    startNewGame();
  }

  void startNewGame() {
    final availableCells = emptyGrid
        .expandIndexed((row, tiles) => List.generate(
              tiles.length,
              (col) => Cell(row, col),
            ))
        .toList()
      ..shuffle();
    final newGridTileMovements = <GridTileMovement>[];
    for (int i = 0; i < initialTiles; i++) {
      newGridTileMovements.add(
        GridTileMovement.add(availableCells[i].toInitialGridTile()),
      );
    }
    setState(() {
      gridTileMovements = newGridTileMovements;
    });
    final addedGridTiles = gridTileMovements.map((e) => e.toGridTile).toList();
    setState(() {
      grids = emptyGrid.map2D((row, col, _) {
        return addedGridTiles
            .firstWhereOrNull(
                (element) => row == element.cell.row && col == element.cell.col)
            ?.tile;
      }).toList();
      currentScore = 0;
      isGameOver = false;
    });
  }

  void move(Direction direction) {
    var (updatedGrid, updatedGridTileMovements) = makeMove(grids, direction);

    if (!hasGridChanged(updatedGridTileMovements)) {
      // No tiles were moved.
      return;
    }

    final scoreIncrement = updatedGridTileMovements
        .where((element) => element.fromGridTile == null)
        .toList()
        .sumOf((value) => value.toGridTile.tile.number);

    setState(() {
      currentScore += scoreIncrement;
      bestScore = max(bestScore, currentScore);
    });

    final addedTileMovement = createRandomAddedTile(updatedGrid);
    if (addedTileMovement != null) {
      final gridTile = addedTileMovement.toGridTile;

      setState(() {
        updatedGrid = updatedGrid.map2D(
          (row, column, tile) =>
              gridTile.cell.row == row && gridTile.cell.col == column
                  ? gridTile.tile
                  : tile,
        );
        updatedGridTileMovements.add(addedTileMovement);
      });
    }

    setState(() {
      grids = updatedGrid;
      gridTileMovements = updatedGridTileMovements
        ..sort((a, _) => a.fromGridTile == null ? 1 : -1);
      isGameOver = checkIfGameOver(direction);
    });
    if (isGameOver) {
      StartNewGameDialog.show(context);
    }
  }

  bool checkIfGameOver(Direction direction) {
    return Direction.values
        .none((value) => hasGridChanged(makeMove(grids, value).$2));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = kIsWeb ? 400 : size.width - margin;
    final tileSize = ((width - gridSpacing * (gridSize - 1)) / gridSize) < 0
        ? 0.0
        : ((width - gridSpacing * (gridSize - 1)) / gridSize);

    return Scaffold(
      backgroundColor: Colors.white,
      //dark mode: const Color(0xFF100F13),
      appBar: AppBar(
        title: const Text('2048'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => StartNewGameDialog.show(
              context,
              onOkPressed: () => startNewGame(),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Focus(
        autofocus: true,
        focusNode: _focusNode,
        onKeyEvent: (node, event) => _handleKeyEvent(event),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: margin / 2),
          child: Column(
            children: [
              SizedBox(
                height: (tileSize + gridSpacing) * gridSize,
                width: double.infinity,
                child: _GridViewStack(
                  tileSize: tileSize,
                  gridSpacing: gridSpacing,
                  gridTileMovements: gridTileMovements,
                ),
              ),
              const SizedBox(height: 20),
              ScoresTile(
                bestScore: bestScore.toString(),
                currentScore: currentScore.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final direction = event.direction;
      if (activeKeyDown == null && direction != null) {
        setState(() {
          activeKeyDown = event.logicalKey;
        });
        move(direction);
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == activeKeyDown) {
        setState(() {
          activeKeyDown = null;
        });
      }
    }
    return KeyEventResult.handled;
  }
}

class _GridViewStack extends StatelessWidget {
  const _GridViewStack({
    required this.tileSize,
    required this.gridSpacing,
    required this.gridTileMovements,
  });

  final double tileSize;
  final double gridSpacing;
  final List<GridTileMovement> gridTileMovements;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GridViewWidget(
            gridSize: gridSize,
            tileSize: tileSize,
            gridSpacing: gridSpacing,
          ),
        ),
        for (var gridTileMovement in gridTileMovements)
          () {
            final tile = gridTileMovement.toGridTile.tile;
            final initialCell = gridTileMovement.fromGridTile?.cell ??
                gridTileMovement.toGridTile.cell;
            final offset = (tileSize + gridSpacing);
            print('Initial row ${initialCell.row}');
            print('Initial col ${initialCell.col}');
            print(
                "CurrentOffset ${initialCell.col * offset}, ${initialCell.row * offset}");
            print("===================================");
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              right: initialCell.col * offset,
              top: initialCell.row * offset,
              child: GridTileWidget(
                key: ValueKey(tile.id),
                gridTileMovement: gridTileMovement,
                tileSize: tileSize,
              ),
            );
            //106.0, 318.0
            //752.25, 250.75
          }()
      ],
    );
  }
}
