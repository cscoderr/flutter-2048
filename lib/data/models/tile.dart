class Tile {
  Tile(this.number) : id = _tileIdCounter++;

  final int number;
  final int id;

  static int _tileIdCounter = 0;

  Tile operator *(int operand) {
    return Tile(number * operand);
  }
}
