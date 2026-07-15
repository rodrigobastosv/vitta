// One-time/occasional bulk import of the free-exercise-db dataset into the
// shared `exercises` catalog (see supabase/schema.sql), mirroring its photos
// into the `exercise-images` Storage bucket and translating its English-only
// text into pt via Claude.
//
// The dataset is public domain (Unlicense), ~873 exercises, every one with at
// least one photo:  https://github.com/yuhonas/free-exercise-db
//
//   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... ANTHROPIC_API_KEY=... \
//   dart run tool/import_exercise_catalog.dart
//
// Safe to re-run: rows upsert on `slug` (merge-duplicates), image uploads pass
// x-upsert, and by default an exercise already in the catalog is skipped
// entirely (IMPORT_SKIP_EXISTING) so an interrupted run resumes where it left
// off rather than re-paying for translation. Pass IMPORT_SKIP_EXISTING=false to
// force a full refresh - that re-translates everything, so it costs real money.
//
// Images are mirrored rather than hot-linked to raw.githubusercontent.com: that
// host is rate-limited, unversioned, and could disappear, and `foods` already
// established that a catalog image lives in our own Storage bucket. ~1746
// images at ~55KB average is ~96MB, comfortably inside the free tier.
//
// The translation is the one step that costs money (~$5-10 for a full run) and
// the only reason ANTHROPIC_API_KEY is needed. It's a plain HTTPS call rather
// than an SDK because Dart has no official Anthropic SDK. Unlike the app's
// nutrition scan (which must proxy through a Supabase Edge Function so the API
// key never ships in the binary), this is a one-off developer script run from a
// trusted shell, so it talks to the API directly. Structured outputs guarantee
// the response parses, so there's no defensive parsing below.
//
// SUPABASE_SERVICE_ROLE_KEY bypasses RLS - it's what lets imported rows have a
// null user_id. Never put it in .env (flutter_dotenv loads that file into the
// shipped app) or commit it anywhere. Pass it as a one-off shell environment
// variable only, same as tool/import_food_catalog.dart.
//
// Requires supabase/schema.sql to have been re-run first (the `exercises` table
// and the `exercise-images` bucket must exist).
//
// Optional env vars:
//   EXERCISE_DB_PATH=exercises.json     local dataset instead of downloading
//   EXERCISE_DB_URL=...                 override the dataset URL
//   IMPORT_SKIP_EXISTING=false          re-import rows already in the catalog
//   IMPORT_TRANSLATE=false              skip Claude; import English only
//   IMPORT_IMAGES=false                 skip Storage uploads (no image_urls)
//   IMPORT_MAX_EXERCISES=50             stop after N (for a cheap smoke test)
//   IMPORT_BATCH_SIZE=8                 exercises per translation request
//   ANTHROPIC_MODEL=claude-opus-4-8     model used for the translation

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _datasetUrl = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json';
const _imageBaseUrl = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises';
const _anthropicUrl = 'https://api.anthropic.com/v1/messages';
const _anthropicVersion = '2023-06-01';
const _defaultModel = 'claude-opus-4-8';
const _defaultBatchSize = 8;
const _bucket = 'exercise-images';

// package:http waits forever by default, so without these a single stalled
// connection hangs the whole run with no output and no way to tell it apart
// from slow progress. Translation gets the long one: it's a model call, not a
// file transfer.
const _requestTimeout = Duration(seconds: 45);
const _translationTimeout = Duration(minutes: 5);
const _maxAttempts = 4;

// The dataset's values are already snake_case-ish but not consistently: it uses
// spaces and hyphens where the app's enums use underscores (see
// lib/app/domain/workout/entities/). Anything not in these maps is dropped
// rather than guessed - the column check constraints would reject it anyway.
const _equipmentWireValues = {
  'barbell': 'barbell',
  'dumbbell': 'dumbbell',
  'kettlebells': 'kettlebells',
  'cable': 'cable',
  'machine': 'machine',
  'bands': 'bands',
  'body only': 'body_only',
  'exercise ball': 'exercise_ball',
  'medicine ball': 'medicine_ball',
  'foam roll': 'foam_roll',
  'e-z curl bar': 'e_z_curl_bar',
  'other': 'other',
};

const _categoryWireValues = {
  'strength': 'strength',
  'cardio': 'cardio',
  'stretching': 'stretching',
  'plyometrics': 'plyometrics',
  'powerlifting': 'powerlifting',
  'olympic weightlifting': 'olympic_weightlifting',
  'strongman': 'strongman',
};

const _muscleWireValues = {
  'abdominals': 'abdominals',
  'abductors': 'abductors',
  'adductors': 'adductors',
  'biceps': 'biceps',
  'calves': 'calves',
  'chest': 'chest',
  'forearms': 'forearms',
  'glutes': 'glutes',
  'hamstrings': 'hamstrings',
  'lats': 'lats',
  'lower back': 'lower_back',
  'middle back': 'middle_back',
  'neck': 'neck',
  'quadriceps': 'quadriceps',
  'shoulders': 'shoulders',
  'traps': 'traps',
  'triceps': 'triceps',
};

Future<void> main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final serviceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  if (supabaseUrl == null || serviceRoleKey == null) {
    stderr.writeln('Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables first.');
    exit(1);
  }

  final translate = Platform.environment['IMPORT_TRANSLATE'] != 'false';
  final anthropicKey = Platform.environment['ANTHROPIC_API_KEY'];
  if (translate && anthropicKey == null) {
    stderr.writeln('Set ANTHROPIC_API_KEY (or pass IMPORT_TRANSLATE=false to import English only).');
    exit(1);
  }

  final uploadImages = Platform.environment['IMPORT_IMAGES'] != 'false';
  final skipExisting = Platform.environment['IMPORT_SKIP_EXISTING'] != 'false';
  final maxExercises = _envInt('IMPORT_MAX_EXERCISES');
  final batchSize = _envInt('IMPORT_BATCH_SIZE') ?? _defaultBatchSize;
  final model = Platform.environment['ANTHROPIC_MODEL'] ?? _defaultModel;

  final client = http.Client();
  var imported = 0;
  var skipped = 0;
  var imagesUploaded = 0;

  try {
    final exercises = await _loadDataset(client);
    stdout.writeln('Loaded ${exercises.length} exercises.');

    final existingSlugs = skipExisting
        ? await _fetchExistingSlugs(client, supabaseUrl: supabaseUrl, serviceRoleKey: serviceRoleKey)
        : <String>{};
    if (existingSlugs.isNotEmpty) {
      stdout.writeln('Catalog already has ${existingSlugs.length} exercises; those are skipped.');
    }

    final pending = <Map<String, dynamic>>[];
    for (final exercise in exercises) {
      final slug = exercise['id'] as String?;
      if (slug == null || existingSlugs.contains(slug)) {
        skipped++;
        continue;
      }
      pending.add(exercise);
      if (maxExercises != null && pending.length >= maxExercises) {
        break;
      }
    }
    stdout.writeln('Importing ${pending.length} exercises (translate: $translate, images: $uploadImages).');

    for (var start = 0; start < pending.length; start += batchSize) {
      final batch = pending.sublist(start, (start + batchSize).clamp(0, pending.length));

      final translations = translate
          ? await _translateBatch(client, batch: batch, apiKey: anthropicKey!, model: model)
          : <String, _Translation>{};

      final rows = <Map<String, dynamic>>[];
      for (final exercise in batch) {
        final slug = exercise['id'] as String;
        // Printed before the work, not after: mirroring an exercise's images is
        // the slowest step, so naming it up front is what tells you a long
        // pause is one slow download rather than a wedged run.
        stdout.writeln('  [${imported + rows.length + 1}/${pending.length}] $slug');
        final imageUrls = uploadImages
            ? await _mirrorImages(client, exercise: exercise, supabaseUrl: supabaseUrl, serviceRoleKey: serviceRoleKey)
            : <String>[];
        imagesUploaded += imageUrls.length;
        rows.add(_toExerciseRow(exercise, translation: translations[slug], imageUrls: imageUrls));
      }

      await _upsertRows(client, supabaseUrl: supabaseUrl, serviceRoleKey: serviceRoleKey, rows: rows);
      imported += rows.length;
      stdout.writeln('  saved $imported/${pending.length} (images uploaded: $imagesUploaded)');
    }
  } on Exception catch (error) {
    // A network failure that survived _send's retries. Report what was already
    // saved rather than dumping a stack trace: every batch is upserted as it
    // completes, so re-running resumes from here (IMPORT_SKIP_EXISTING).
    stderr.writeln('\nImport stopped after $imported exercises: $error');
    stderr.writeln('Re-run the same command to resume - already-imported exercises are skipped.');
    exit(1);
  } finally {
    client.close();
  }

  stdout.writeln('Done. Imported $imported, skipped $skipped, uploaded $imagesUploaded images.');
}

/// Every outbound call goes through here. Two things it buys: a timeout (so a
/// stalled connection fails instead of hanging the run forever with no output),
/// and a retry with backoff on the failures that are worth retrying - a timeout,
/// a dropped socket, a 429 from GitHub raw (which throttles unauthenticated
/// image fetches), or a 5xx. A 4xx other than 429 is returned as-is: a bad key
/// or a rejected row will fail identically on every attempt.
Future<http.Response> _send(Future<http.Response> Function() request, {required String description, required Duration timeout}) async {
  for (var attempt = 1; ; attempt++) {
    try {
      final response = await request().timeout(timeout);
      if (response.statusCode != 429 && response.statusCode < 500) {
        return response;
      }
      if (attempt >= _maxAttempts) {
        return response;
      }
      final retryAfter = int.tryParse(response.headers['retry-after'] ?? '');
      final delay = retryAfter != null ? Duration(seconds: retryAfter) : Duration(seconds: 2 << attempt);
      stderr.writeln('  $description got ${response.statusCode}; retrying in ${delay.inSeconds}s (attempt $attempt/$_maxAttempts)');
      await Future<void>.delayed(delay);
    } on Exception catch (error) {
      if (attempt >= _maxAttempts) {
        rethrow;
      }
      final delay = Duration(seconds: 2 << attempt);
      stderr.writeln('  $description failed ($error); retrying in ${delay.inSeconds}s (attempt $attempt/$_maxAttempts)');
      await Future<void>.delayed(delay);
    }
  }
}

Future<List<Map<String, dynamic>>> _loadDataset(http.Client client) async {
  final path = Platform.environment['EXERCISE_DB_PATH'];
  final url = Platform.environment['EXERCISE_DB_URL'] ?? _datasetUrl;
  final String body;
  if (path != null) {
    stdout.writeln('Reading dataset from $path');
    body = await File(path).readAsString();
  } else {
    stdout.writeln('Downloading dataset from $url');
    final response = await _send(() => client.get(Uri.parse(url)), description: 'dataset download', timeout: _translationTimeout);
    if (response.statusCode != 200) {
      stderr.writeln('Failed to download dataset (${response.statusCode}).');
      exit(1);
    }
    body = response.body;
  }
  return (jsonDecode(body) as List<dynamic>).cast<Map<String, dynamic>>();
}

// PostgREST caps a response at 1000 rows by default, so the catalog is paged
// through rather than fetched in one request - it's already ~873 rows and will
// only grow as users add their own.
Future<Set<String>> _fetchExistingSlugs(http.Client client, {required String supabaseUrl, required String serviceRoleKey}) async {
  final slugs = <String>{};
  const pageSize = 1000;
  for (var offset = 0; ; offset += pageSize) {
    final uri = Uri.parse('$supabaseUrl/rest/v1/exercises?select=slug&slug=not.is.null&limit=$pageSize&offset=$offset');
    final response = await _send(
      () => client.get(uri, headers: _restHeaders(serviceRoleKey)),
      description: 'existing exercises',
      timeout: _requestTimeout,
    );
    if (response.statusCode >= 300) {
      stderr.writeln('Failed to read existing exercises (${response.statusCode}): ${response.body}');
      exit(1);
    }
    final rows = (jsonDecode(response.body) as List<dynamic>).cast<Map<String, dynamic>>();
    slugs.addAll(rows.map((row) => row['slug'] as String));
    if (rows.length < pageSize) {
      return slugs;
    }
  }
}

// Uploads every photo of one exercise and returns their public URLs in the
// dataset's own order (its images are ordered start-position first, so the
// first one is what the app shows as the thumbnail).
Future<List<String>> _mirrorImages(
  http.Client client, {
  required Map<String, dynamic> exercise,
  required String supabaseUrl,
  required String serviceRoleKey,
}) async {
  final images = (exercise['images'] as List<dynamic>?)?.cast<String>() ?? const [];
  final urls = <String>[];
  for (final image in images) {
    final source = await _send(() => client.get(Uri.parse('$_imageBaseUrl/$image')), description: 'image $image', timeout: _requestTimeout);
    if (source.statusCode != 200) {
      stderr.writeln('  skipped image $image (${source.statusCode})');
      continue;
    }
    final uri = Uri.parse('$supabaseUrl/storage/v1/object/$_bucket/$image');
    final upload = await _send(
      () => client.post(
        uri,
        headers: {
          'apikey': serviceRoleKey,
          'Authorization': 'Bearer $serviceRoleKey',
          'Content-Type': 'image/jpeg',
          // Makes the upload idempotent: a re-run overwrites the object
          // instead of failing with "the resource already exists".
          'x-upsert': 'true',
        },
        body: source.bodyBytes,
      ),
      description: 'upload $image',
      timeout: _requestTimeout,
    );
    if (upload.statusCode >= 300) {
      stderr.writeln('  failed to upload $image (${upload.statusCode}): ${upload.body}');
      continue;
    }
    urls.add('$supabaseUrl/storage/v1/object/public/$_bucket/${Uri.encodeComponent(image).replaceAll('%2F', '/')}');
  }
  return urls;
}

class _Translation {
  _Translation({required this.name, required this.instructions});

  final String name;
  final List<String> instructions;
}

// Translates a batch in one request, keyed by the dataset's slug so a response
// can't be silently misaligned with the batch by position. Structured outputs
// guarantee the shape, so the parse below needs no fallbacks.
Future<Map<String, _Translation>> _translateBatch(
  http.Client client, {
  required List<Map<String, dynamic>> batch,
  required String apiKey,
  required String model,
}) async {
  final payload = [
    for (final exercise in batch) {'slug': exercise['id'], 'name': exercise['name'], 'instructions': exercise['instructions'] ?? const []},
  ];

  final response = await _send(
    () => client.post(
      Uri.parse(_anthropicUrl),
      headers: {'x-api-key': apiKey, 'anthropic-version': _anthropicVersion, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': model,
        'max_tokens': 8000,
        'system':
            'You translate strength-training exercise names and instructions from English to Brazilian Portuguese. '
            'Use the term a lifter would actually say in a Brazilian gym (e.g. "Incline Dumbbell Press" is '
            '"Supino inclinado com halteres", "Barbell Curl" is "Rosca direta com barra"), not a literal word-for-word '
            'translation. Keep equipment and anatomy terms consistent across exercises. Translate every instruction '
            'step, preserving the order and the number of steps, and keep the imperative voice the original uses. '
            'Return every exercise you were given, echoing its slug back unchanged.',
        'messages': [
          {'role': 'user', 'content': 'Translate these exercises:\n${jsonEncode(payload)}'},
        ],
        'output_config': {
          'format': {
            'type': 'json_schema',
            'schema': {
              'type': 'object',
              'properties': {
                'translations': {
                  'type': 'array',
                  'items': {
                    'type': 'object',
                    'properties': {
                      'slug': {'type': 'string'},
                      'name': {'type': 'string'},
                      'instructions': {
                        'type': 'array',
                        'items': {'type': 'string'},
                      },
                    },
                    'required': ['slug', 'name', 'instructions'],
                    'additionalProperties': false,
                  },
                },
              },
              'required': ['translations'],
              'additionalProperties': false,
            },
          },
        },
      }),
    ),
    description: 'translation',
    timeout: _translationTimeout,
  );

  if (response.statusCode >= 300) {
    stderr.writeln('Translation failed (${response.statusCode}): ${response.body}');
    exit(1);
  }

  final message = jsonDecode(response.body) as Map<String, dynamic>;
  // A safety refusal returns HTTP 200 with an empty content array, so the
  // stop_reason has to be checked before reading content.
  if (message['stop_reason'] == 'refusal') {
    stderr.writeln('Translation refused for batch starting at "${batch.first['id']}".');
    exit(1);
  }
  final content = (message['content'] as List<dynamic>).cast<Map<String, dynamic>>();
  final text = content.firstWhere((block) => block['type'] == 'text')['text'] as String;
  final translations = (jsonDecode(text) as Map<String, dynamic>)['translations'] as List<dynamic>;

  return {
    for (final translation in translations.cast<Map<String, dynamic>>())
      translation['slug'] as String: _Translation(
        name: translation['name'] as String,
        instructions: (translation['instructions'] as List<dynamic>).cast<String>(),
      ),
  };
}

// user_id is intentionally omitted rather than set to null, exactly as
// import_food_catalog.dart does: on insert the column falls back to its null
// default (imported rows are unowned), and on the slug DO UPDATE an absent
// column is left untouched, so a re-run never reassigns a row's owner.
Map<String, dynamic> _toExerciseRow(Map<String, dynamic> exercise, {required _Translation? translation, required List<String> imageUrls}) {
  final englishInstructions = (exercise['instructions'] as List<dynamic>?)?.cast<String>() ?? const <String>[];
  return {
    'slug': exercise['id'],
    'names': {'en': exercise['name'], if (translation != null) 'pt': translation.name},
    'instructions': {'en': englishInstructions, if (translation != null) 'pt': translation.instructions},
    'category': _categoryWireValues[exercise['category']] ?? 'strength',
    'equipment': _equipmentWireValues[exercise['equipment']],
    'force': exercise['force'],
    'level': exercise['level'] ?? 'beginner',
    'mechanic': exercise['mechanic'],
    'primary_muscles': _muscleWires(exercise['primaryMuscles']),
    'secondary_muscles': _muscleWires(exercise['secondaryMuscles']),
    'image_urls': imageUrls,
  };
}

List<String> _muscleWires(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return [for (final muscle in raw.cast<String>()) ?_muscleWireValues[muscle]];
}

Future<void> _upsertRows(
  http.Client client, {
  required String supabaseUrl,
  required String serviceRoleKey,
  required List<Map<String, dynamic>> rows,
}) async {
  final uri = Uri.parse('$supabaseUrl/rest/v1/exercises?on_conflict=slug');
  final response = await _send(
    () => client.post(
      uri,
      headers: {..._restHeaders(serviceRoleKey), 'Prefer': 'resolution=merge-duplicates,return=minimal'},
      body: jsonEncode(rows),
    ),
    description: 'upsert',
    timeout: _requestTimeout,
  );
  if (response.statusCode >= 300) {
    // Fail the whole run rather than logging and moving on: a rejected batch
    // means every batch after it is rejected the same way (a missing table, a
    // check constraint the dataset violates, a bad key), and continuing would
    // print a reassuring "Done. Imported 873" while the catalog stayed empty.
    stderr.writeln('Upsert failed (${response.statusCode}): ${response.body}');
    stderr.writeln('Nothing after this batch was imported. Re-run supabase/schema.sql if the table or a column is missing.');
    exit(1);
  }
}

Map<String, String> _restHeaders(String serviceRoleKey) => {
  'apikey': serviceRoleKey,
  'Authorization': 'Bearer $serviceRoleKey',
  'Content-Type': 'application/json',
};

int? _envInt(String key) {
  final raw = Platform.environment[key];
  return raw == null ? null : int.tryParse(raw.trim());
}
