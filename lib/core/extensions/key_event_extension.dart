import 'package:flutter/services.dart';
import 'package:flutter_2048/core/core.dart';

extension KeyEventExtension on KeyEvent {
  Direction? get direction => switch (logicalKey) {
        LogicalKeyboardKey.arrowUp ||
        LogicalKeyboardKey.keyW =>
          Direction.north,
        LogicalKeyboardKey.arrowLeft ||
        LogicalKeyboardKey.keyA =>
          Direction.west,
        LogicalKeyboardKey.arrowDown ||
        LogicalKeyboardKey.keyS =>
          Direction.south,
        LogicalKeyboardKey.arrowRight ||
        LogicalKeyboardKey.keyD =>
          Direction.east,
        _ => null
      };
}
