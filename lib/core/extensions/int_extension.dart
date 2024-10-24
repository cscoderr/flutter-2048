extension IntEx on int {
  int floorMod(int other) {
    final mod = this % other;
    return ((mod ^ other) < 0 && mod != 0) ? mod + other : mod;
  }
}
