import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class StorageService {
  const StorageService({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;
  final SharedPreferences _sharedPreferences;

  String? read(String key) => _sharedPreferences.getString(key);

  Future<bool> save(String key, String value) =>
      _sharedPreferences.setString(key, value);

  Future<bool> clear() => _sharedPreferences.clear();

  void clearAll() {}
}

final storageServiceProvider = Provider<StorageService>(
    (ref) => StorageService(sharedPreferences: ref.read(sharedPrefsProvider)));
