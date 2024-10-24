extension ListEx<T> on List<T> {
  int sumOf(int Function(T) selector) {
    int sum = 0;
    for (var element in this) {
      sum += selector(element);
    }
    return sum;
  }

  bool none(bool Function(T) predicate) {
    if (isEmpty) return true;
    for (var element in this) {
      if (predicate(element)) return false;
    }
    return true;
  }
}
