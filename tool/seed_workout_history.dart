// Seeds a few weeks of workout history for one exercise so the load-progression
// screen (issue #97) has something real to show. Development convenience only -
// it writes rows into `workouts`, `workout_exercises` and `workout_sets` for a
// single user, with a load that climbs session over session so e1RM and heaviest
// load trend upward.
//
//   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... dart run tool/seed_workout_history.dart
//
// SUPABASE_SERVICE_ROLE_KEY bypasses RLS - it's the only way to write rows owned
// by an anonymous user without holding that user's session. Never put it in .env
// (flutter_dotenv loads that into the shipped app) or commit it; pass it as a
// one-off shell variable, same as the import tools.
//
// Optional env vars:
//   SEED_USER_ID=<uuid>            user to own the history; defaults to the most
//                                  recently created auth user (printed for you)
//   SEED_EXERCISE_SLUG=<slug>      exercise to seed; takes precedence over name
//   SEED_EXERCISE_NAME=Bench Press exercise picked by name match (default)
//   SEED_SESSIONS=8                how many past weekly sessions to write
//   SEED_BASE_WEIGHT_KG=60         load of the oldest session
//   SEED_WEIGHT_STEP_KG=2.5        added each session, so the trend climbs

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _requestTimeout = Duration(seconds: 30);

Future<void> main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final serviceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  if (supabaseUrl == null || serviceRoleKey == null) {
    stderr.writeln('Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables first.');
    exitCode = 1;
    return;
  }

  final sessions = _envInt('SEED_SESSIONS') ?? 8;
  final baseWeight = _envDouble('SEED_BASE_WEIGHT_KG') ?? 60;
  final weightStep = _envDouble('SEED_WEIGHT_STEP_KG') ?? 2.5;

  final client = http.Client();
  try {
    final userId = Platform.environment['SEED_USER_ID'] ?? await _mostRecentUserId(client, supabaseUrl, serviceRoleKey);
    if (userId == null) {
      stderr.writeln('No SEED_USER_ID given and no auth users found. Open the app once, then re-run.');
      exitCode = 1;
      return;
    }
    stdout.writeln('Seeding history for user $userId');

    final exercise = await _resolveExercise(client, supabaseUrl, serviceRoleKey);
    if (exercise == null) {
      stderr.writeln('Could not find an exercise to seed. Set SEED_EXERCISE_SLUG or SEED_EXERCISE_NAME.');
      exitCode = 1;
      return;
    }
    stdout.writeln('Exercise: ${exercise.name} (${exercise.id})');

    final today = DateTime.now();
    for (var index = 0; index < sessions; index++) {
      final weeksAgo = sessions - 1 - index;
      final performedDate = _dateString(today.subtract(Duration(days: weeksAgo * 7)));
      final weight = baseWeight + weightStep * index;

      final workoutId = await _insertReturningId(
        client,
        supabaseUrl,
        serviceRoleKey,
        table: 'workouts',
        row: {'user_id': userId, 'performed_date': performedDate},
      );
      final workoutExerciseId = await _insertReturningId(
        client,
        supabaseUrl,
        serviceRoleKey,
        table: 'workout_exercises',
        row: {
          'workout_id': workoutId,
          'exercise_id': exercise.id,
          'position': 0,
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
      final setRows = [
        for (final (position, reps) in const [(0, 10), (1, 10), (2, 8)])
          {'workout_exercise_id': workoutExerciseId, 'position': position, 'reps': reps, 'weight_kg': weight},
      ];
      await _insert(client, supabaseUrl, serviceRoleKey, table: 'workout_sets', rows: setRows);
      stdout.writeln('  $performedDate: 3 sets @ ${weight.toStringAsFixed(1)} kg');
    }
    stdout.writeln('Done. Seeded $sessions sessions.');
  } finally {
    client.close();
  }
}

class _Exercise {
  const _Exercise({required this.id, required this.name});

  final String id;
  final String name;
}

Future<_Exercise?> _resolveExercise(http.Client client, String supabaseUrl, String serviceRoleKey) async {
  final slug = Platform.environment['SEED_EXERCISE_SLUG'];
  final name = Platform.environment['SEED_EXERCISE_NAME'] ?? 'bench press';
  final filter = slug != null
      ? 'slug=eq.${Uri.encodeComponent(slug)}'
      : 'search_text=ilike.${Uri.encodeComponent('%${name.toLowerCase()}%')}';
  final uri = Uri.parse('$supabaseUrl/rest/v1/exercises?select=id,names&$filter&order=times_logged.desc&limit=1');
  final response = await client.get(uri, headers: _restHeaders(serviceRoleKey)).timeout(_requestTimeout);
  if (response.statusCode != 200) {
    throw Exception('Failed to look up exercise: ${response.statusCode} ${response.body}');
  }
  final rows = (jsonDecode(response.body) as List<dynamic>).cast<Map<String, dynamic>>();
  if (rows.isEmpty) {
    return null;
  }
  final row = rows.first;
  final names = (row['names'] as Map<String, dynamic>?) ?? const {};
  final label = (names['en'] ?? names['pt'] ?? names.values.firstOrNull ?? 'Exercise').toString();
  return _Exercise(id: row['id'] as String, name: label);
}

Future<String?> _mostRecentUserId(http.Client client, String supabaseUrl, String serviceRoleKey) async {
  final uri = Uri.parse('$supabaseUrl/auth/v1/admin/users?page=1&per_page=20');
  final response = await client.get(uri, headers: _restHeaders(serviceRoleKey)).timeout(_requestTimeout);
  if (response.statusCode != 200) {
    throw Exception('Failed to list users: ${response.statusCode} ${response.body}');
  }
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  final users = (body['users'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
  if (users.isEmpty) {
    return null;
  }
  String activity(Map<String, dynamic> user) => (user['last_sign_in_at'] ?? user['created_at'] ?? '').toString();
  users.sort((a, b) => activity(b).compareTo(activity(a)));
  if (users.length > 1) {
    stdout.writeln('Found ${users.length} users; picking the most recently active. Pass SEED_USER_ID to override:');
    for (final user in users.take(5)) {
      stdout.writeln('  ${user['id']}  last active ${activity(user)}');
    }
  }
  return users.first['id'] as String;
}

Future<String> _insertReturningId(
  http.Client client,
  String supabaseUrl,
  String serviceRoleKey, {
  required String table,
  required Map<String, dynamic> row,
}) async {
  final uri = Uri.parse('$supabaseUrl/rest/v1/$table?select=id');
  final response = await client
      .post(
        uri,
        headers: {..._restHeaders(serviceRoleKey), 'Prefer': 'return=representation'},
        body: jsonEncode([row]),
      )
      .timeout(_requestTimeout);
  if (response.statusCode != 201) {
    throw Exception('Failed to insert into $table: ${response.statusCode} ${response.body}');
  }
  final rows = (jsonDecode(response.body) as List<dynamic>).cast<Map<String, dynamic>>();
  return rows.first['id'] as String;
}

Future<void> _insert(
  http.Client client,
  String supabaseUrl,
  String serviceRoleKey, {
  required String table,
  required List<Map<String, dynamic>> rows,
}) async {
  final uri = Uri.parse('$supabaseUrl/rest/v1/$table');
  final response = await client
      .post(
        uri,
        headers: {..._restHeaders(serviceRoleKey), 'Prefer': 'return=minimal'},
        body: jsonEncode(rows),
      )
      .timeout(_requestTimeout);
  if (response.statusCode != 201) {
    throw Exception('Failed to insert into $table: ${response.statusCode} ${response.body}');
  }
}

Map<String, String> _restHeaders(String serviceRoleKey) => {
  'apikey': serviceRoleKey,
  'Authorization': 'Bearer $serviceRoleKey',
  'Content-Type': 'application/json',
};

String _dateString(DateTime date) => date.toIso8601String().split('T').first;

int? _envInt(String key) {
  final raw = Platform.environment[key];
  return raw == null ? null : int.tryParse(raw.trim());
}

double? _envDouble(String key) {
  final raw = Platform.environment[key];
  return raw == null ? null : double.tryParse(raw.trim());
}
