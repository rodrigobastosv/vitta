import 'package:hive_ce/hive.dart';
import 'package:vitta/app/core/storage/local_storage_service.dart';

class HiveLocalStorageService implements LocalStorageService {
  HiveLocalStorageService({required Box<dynamic> box}) : _box = box;

  final Box<dynamic> _box;

  @override
  T? get<T>(String key) => _box.get(key) as T?;

  @override
  Future<void> put<T>(String key, T value) => _box.put(key, value);

  @override
  Future<void> delete(String key) => _box.delete(key);
}
