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
    List<List<Tile?>> grids, Direction direction) {
  final numRotations = switch (direction) {
    Direction.west => 0,
    Direction.south => 1,
    Direction.east => 2,
    Direction.north => 3,
  };

  var updatedGrid = grids.rotate(numRotations);

  final gridTileMovements = <GridTileMovement>[];

  updatedGrid = List.generate(
    updatedGrid.length,
    (currentRowIndex) {
      final tiles = updatedGrid[currentRowIndex];
      int? lastSeenTileIndex;
      int? lastSeenEmptyIndex;
      for (int currentColIndex = 0;
          currentColIndex < tiles.length;
          currentColIndex++) {
        final currentTile = tiles[currentColIndex];

        if (currentTile == null) {
          // We are looking at an empty cell in the grid.
          lastSeenEmptyIndex ??= currentColIndex;
          continue;
        }

        final currentGridTile = GridTile(
            getRotatedCellAt(
              currentRowIndex,
              currentColIndex,
              numRotations,
            ),
            currentTile);

        if (lastSeenTileIndex == null) {
          if (lastSeenEmptyIndex == null) {
            gridTileMovements.add(GridTileMovement.noop(currentGridTile));
            lastSeenTileIndex = currentColIndex;
          } else {
            final targetCell = getRotatedCellAt(
                currentRowIndex, lastSeenEmptyIndex, numRotations);
            final targetGridTile = GridTile(targetCell, currentTile);
            gridTileMovements
                .add(GridTileMovement.shift(currentGridTile, targetGridTile));

            tiles[lastSeenEmptyIndex] = currentTile;
            tiles[currentColIndex] = null;
            lastSeenTileIndex = lastSeenEmptyIndex;
            lastSeenEmptyIndex++;
          }
        } else {
          if (tiles[lastSeenTileIndex]!.number == currentTile.number) {
            // Shift the tile to the location where it will be merged.
            final targetCell = getRotatedCellAt(
                currentRowIndex, lastSeenTileIndex, numRotations);
            gridTileMovements.add(
              GridTileMovement.shift(
                currentGridTile,
                GridTile(targetCell, currentTile),
              ),
            );

            // Merge the current tile with the previous tile.
            final addedTile = currentTile * 2;
            gridTileMovements.add(
              GridTileMovement.add(
                GridTile(targetCell, addedTile),
              ),
            );

            tiles[lastSeenTileIndex] = addedTile;
            tiles[currentColIndex] = null;
            lastSeenTileIndex = null;
            lastSeenEmptyIndex ??= currentColIndex;
          } else {
            if (lastSeenEmptyIndex == null) {
              // Keep the tile at its same location.

              gridTileMovements.add(GridTileMovement.noop(currentGridTile));
            } else {
              // Shift the current tile towards the previous tile.
              final targetCell = getRotatedCellAt(
                  currentRowIndex, lastSeenEmptyIndex, numRotations);
              final targetGridTile = GridTile(targetCell, currentTile);
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
    },
  );

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
          AnimatedGridChild(
            gridTileMovement: gridTileMovement,
            offset: tileSize + gridSpacing,
            key: ValueKey(gridTileMovement.toGridTile.tile.id),
            child: AnimatedContainer(
              height: tileSize,
              width: tileSize,
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: gridTileColor(
                    gridTileMovement.toGridTile.tile.number, false),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                gridTileMovement.toGridTile.tile.number.toString(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 24,
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        //106.0, 318.0
      ],
    );
  }
}

class AnimatedGridChild extends StatefulWidget {
  const AnimatedGridChild({
    super.key,
    required this.child,
    required this.gridTileMovement,
    required this.offset,
  });

  final Widget child;
  final GridTileMovement gridTileMovement;
  final double offset;

  @override
  State<AnimatedGridChild> createState() => _AnimatedGridChildState();
}

class _AnimatedGridChildState extends State<AnimatedGridChild>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _offsetAnimation;
  late final Tile _tile = widget.gridTileMovement.toGridTile.tile;
  late final Cell _initialCell = widget.gridTileMovement.fromGridTile?.cell ??
      widget.gridTileMovement.toGridTile.cell;
  late final _currentOffset = Offset(
      _initialCell.col * widget.offset, _initialCell.row * widget.offset);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation = Tween(
      begin: widget.gridTileMovement.fromGridTile == null ? 0.0 : 1.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _offsetAnimation = Tween(begin: _currentOffset, end: _currentOffset)
        .animate(_animationController);
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedGridChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cell = oldWidget.gridTileMovement.toGridTile.cell;
    final oldOffset =
        Offset(cell.col * oldWidget.offset, cell.row * oldWidget.offset);
    if (_currentOffset != oldOffset) {
      _offsetAnimation = Tween(begin: _currentOffset, end: oldOffset)
          .animate(_animationController);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offsetAnimation.value,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
