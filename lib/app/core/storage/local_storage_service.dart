abstract class LocalStorageService {
  T? get<T>(String key);

  Future<void> put<T>(String key, T value);

  Future<void> delete(String key);
}
