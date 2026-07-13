import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService({required this._client});

  final SupabaseClient _client;

  GoTrueClient get auth => _client.auth;

  bool get hasSession => _client.auth.currentSession != null;

  String get currentUserId => _client.auth.currentUser!.id;

  bool get isAnonymous => _client.auth.currentUser?.isAnonymous ?? true;

  String? get currentUserEmail => _client.auth.currentUser?.email;

  SupabaseQueryBuilder from(String table) => _client.from(table);

  StorageFileApi storage(String bucket) => _client.storage.from(bucket);
}
