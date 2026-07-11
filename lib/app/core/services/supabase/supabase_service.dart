import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  GoTrueClient get auth => _client.auth;

  bool get hasSession => _client.auth.currentSession != null;

  String get currentUserId => _client.auth.currentUser!.id;

  SupabaseQueryBuilder from(String table) => _client.from(table);
}
