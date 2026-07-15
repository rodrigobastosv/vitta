import 'package:vitta/app/core/services/storage/local_storage_service.dart';

class RecentSearchesLocalDataSource {
  RecentSearchesLocalDataSource({required this._localStorageService});

  final LocalStorageService _localStorageService;

  static const _recentSearchesKey = 'diet.recentSearches';

  /// Read back as `List<dynamic>` and re-cast: Hive stores the element type but
  /// hands the list back untyped, so asking it for a `List<String>` directly
  /// throws.
  List<String> getRecentSearches() => _localStorageService.get<List<dynamic>>(_recentSearchesKey)?.cast<String>() ?? const [];

  Future<void> saveRecentSearches(List<String> queries) => _localStorageService.put(_recentSearchesKey, queries);
}
