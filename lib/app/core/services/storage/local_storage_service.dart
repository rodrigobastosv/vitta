import 'package:hive_ce/hive.dart';

class LocalStorageService {
  LocalStorageService({required this._box});

  final Box<dynamic> _box;

  T? get<T>(String key) => _box.get(key) as T?;

  Future<void> put<T>(String key, T value) => _box.put(key, value);

  Future<void> delete(String key) => _box.delete(key);
}
