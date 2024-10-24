import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/core/core.dart';
import 'package:flutter_2048/data/data.dart';
import 'package:flutter_2048/presentation/game/game.dart';

Cell getRotatedCellAt(int row, int col, int numRotations) {
  return switch (numRotations) {
    0 => Cell(row, col),
    1 => Cell(gridSize - 1 - col, row),
    2 => Cell(gridSize - 1 - row, gridSize - 1 - col),
    3 => Cell(col, gridSize - 1 - row),
    _ => throw ArgumentError('numRotations must be an integer between 0 and 3')
  };
}

GridTileMovement? createRandomAddedTile(List<List<Tile?>> grid) {
  final List<Cell> emptyCells = grid
      .expandIndexed((row, tiles) => tiles
          .mapIndexed((col, element) => element == null ? Cell(row, col) : null)
          .whereNotNull())
      .toList();

  final emptyCell = emptyCells.isNotEmpty
      ? emptyCells[Random().nextInt(emptyCells.length)]
      : null;

  return emptyCell == null
      ? null
      : GridTileMovement.add(emptyCell.toInitialGridTile());
}

bool hasGridChanged(List<GridTileMovement> gridTileMovements) {
  // The grid has changed if any of the tiles have moved to a different location.
  return gridTileMovements.any(
    (element) =>
        element.fromGridTile == null ||
        element.fromGridTile?.cell != element.toGridTile.cell,
  );
}

Color gridTileColor(int number, bool isDarkMode) {
  return switch (number) {
    2 => Color(isDarkMode ? 0xff4e6cef : 0xff50c0e9),
    4 => Color(isDarkMode ? 0xff3f51b5 : 0xff1da9da),
    8 => Color(isDarkMode ? 0xff8e24aa : 0xffcb97e5),
    16 => Color(isDarkMode ? 0xff673ab7 : 0xffb368d9),
    32 => Color(isDarkMode ? 0xffc00c23 : 0xffff5f5f),
    64 => Color(isDarkMode ? 0xffa80716 : 0xffe92727),
    128 => Color(isDarkMode ? 0xff0a7e07 : 0xff92c500),
    256 => Color(isDarkMode ? 0xff056f00 : 0xff7caf00),
    512 => Color(isDarkMode ? 0xffe37c00 : 0xffffc641),
    1024 => Color(isDarkMode ? 0xffd66c00 : 0xffffa713),
    2048 => Color(isDarkMode ? 0xffcf5100 : 0xffff8a00),
    4096 => Color(isDarkMode ? 0xff80020a : 0xffcc0000),
    8192 => Color(isDarkMode ? 0xff303f9f : 0xff0099cc),
    16384 => Color(isDarkMode ? 0xff512da8 : 0xff9933cc),
    _ => Colors.black
  };
}
