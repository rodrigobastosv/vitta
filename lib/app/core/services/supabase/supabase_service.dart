import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitta/app/core/services/supabase/supabase_bucket.dart';
import 'package:vitta/app/core/services/supabase/supabase_function.dart';
import 'package:vitta/app/core/services/supabase/supabase_table.dart';

class SupabaseService {
  SupabaseService({required this._client});

  final SupabaseClient _client;

  GoTrueClient get auth => _client.auth;

  bool get hasSession => _client.auth.currentSession != null;

  /// The signed-in auth.uid() over time, null while there is no session. The
  /// underlying controller replays its latest event to a new listener, so
  /// subscribing is enough to learn who is signed in right now — no separate
  /// initial read.
  Stream<String?> get currentUserIdChanges => _client.auth.onAuthStateChange.map((authState) => authState.session?.user.id);

  String get currentUserId => _client.auth.currentUser!.id;

  bool get isAnonymous => _client.auth.currentUser?.isAnonymous ?? true;

  String? get currentUserEmail => _client.auth.currentUser?.email;

  Map<String, dynamic>? get currentUserMetadata => _client.auth.currentUser?.userMetadata;

  SupabaseQueryBuilder from(SupabaseTable table) => _client.from(table.wireName);

  StorageFileApi storage(SupabaseBucket bucket) => _client.storage.from(bucket.wireName);

  Future<FunctionResponse> invoke(SupabaseFunction function, {required Map<String, dynamic> body}) => _client.functions.invoke(function.wireName, body: body);
}
