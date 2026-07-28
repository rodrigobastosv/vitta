import 'dart:convert';

import 'package:vitta/app/core/services/storage/local_storage_service.dart';

/// Keeps the last rows a Supabase read returned, so a page can open on what it
/// showed last instead of an empty skeleton while the network answers.
///
/// It caches the **wire rows**, not entities: every entity in this app already
/// has a `fromMap` for exactly this shape, so a cached read rebuilds through the
/// same constructor the live read uses and nothing needs a `toMap`. It is stored
/// as one JSON string per key, which keeps `LocalStorageService`'s primitives-only
/// rule intact.
///
/// Cached rows are a *display* value and never a source of truth: the live read
/// always follows and always wins. Nothing is written from the cache, so a stale
/// row cannot become a stale write.
class WireCacheService {
  WireCacheService({required this._localStorageService});

  static const _keyPrefix = 'cache.';
  static const _indexKey = '${_keyPrefix}index';
  static const _maxEntries = 60;

  final LocalStorageService _localStorageService;

  List<Map<String, dynamic>>? read(String key) {
    final encoded = _localStorageService.get<String>('$_keyPrefix$key');
    if (encoded == null) {
      return null;
    }
    try {
      return (jsonDecode(encoded) as List<dynamic>).cast<Map<String, dynamic>>();
    } on FormatException {
      return null;
    }
  }

  Future<void> write(String key, List<Map<String, dynamic>> rows) async {
    await _localStorageService.put('$_keyPrefix$key', jsonEncode(rows));
    await _touch(key);
  }

  Future<void> clear() async {
    for (final key in _index) {
      await _localStorageService.delete('$_keyPrefix$key');
    }
    await _localStorageService.delete(_indexKey);
  }

  List<String> get _index => _localStorageService.get<List<dynamic>>(_indexKey)?.cast<String>() ?? [];

  Future<void> _touch(String key) async {
    final index = [..._index.where((entry) => entry != key), key];
    final evicted = index.length > _maxEntries ? index.sublist(0, index.length - _maxEntries) : const <String>[];
    for (final key in evicted) {
      await _localStorageService.delete('$_keyPrefix$key');
    }
    await _localStorageService.put(_indexKey, index.sublist(evicted.length));
  }
}
