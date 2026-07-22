// Populates `foods.grams_per_unit` so a countable food can be logged as
// "2 eggs" instead of "100 g" (see issue #114 and supabase/schema.sql).
//
//   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... ANTHROPIC_API_KEY=... \
//   dart run tool/populate_food_unit_weights.dart
//
// The converter is ours (issue #211): it asks Claude what one whole item of
// each food weighs, in one batched request per page, the same structured-output
// call tool/import_usda_foods.dart uses to translate names. It replaces the
// public food-gram-converter API this tool used to call - an LLM behind a
// free-tier host that cold-started, rate-limited, answered one food per
// request, and could disappear without notice. Owning the call means one
// request per batch instead of per food, a prompt we can tune against our own
// catalog, and no third-party uptime in the loop.
//
// The judgement asked for is unchanged, because it is the whole feature: a
// countable food gets a weight ("um ovo tipico pesa cerca de 50 g"), and
// anything measured rather than counted - rice is a bulk grain, milk is a
// liquid - comes back not countable. That verdict is the reason this can't be
// read off Open Food Facts' own product_quantity instead: a 1kg bag of rice has
// a product_quantity, and believing it would make rice countable at 1000g per
// unit.
//
// Safe to re-run, and that is what `grams_per_unit_checked_at` is for: every
// answer stamps it, so a re-run only asks about foods nobody has asked about
// yet. Without it a null grams_per_unit would mean both "not countable" and
// "not asked", and every run would re-ask about every bulk food forever.
// A food the model didn't answer for is left unstamped, so the next run picks
// it up.
//
// Foods are processed most-logged-first (foods.times_logged), so a bounded run
// still covers what users actually eat. UNIT_MAX_FOODS is the way to try it
// against a handful of rows before paying for the whole catalog.
//
// SUPABASE_SERVICE_ROLE_KEY bypasses RLS - never put it in .env (flutter_dotenv
// loads that file into the shipped app) or commit it anywhere. Pass it (and
// ANTHROPIC_API_KEY) as a one-off shell environment variable only.
//
// Requires supabase/schema.sql to have been re-run first (foods.grams_per_unit
// and foods.grams_per_unit_checked_at must exist).
//
// Optional env vars:
//   UNIT_MAX_FOODS=...              stop after N foods (default: the whole catalog)
//   UNIT_SOURCE=generic             only ask about one FoodSource (default: every source)
//   UNIT_BATCH_SIZE=25              foods asked about per request
//   UNIT_PAGE_SIZE=100              foods fetched per query
//   ANTHROPIC_MODEL=claude-opus-4-8 model used for the conversion

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _anthropicUrl = 'https://api.anthropic.com/v1/messages';
const _anthropicVersion = '2023-06-01';
const _defaultModel = 'claude-opus-4-8';
const _requestTimeout = Duration(seconds: 45);
const _conversionTimeout = Duration(minutes: 5);
const _maxAttempts = 4;

/// Small enough that one refusal or timeout doesn't cost a whole page, large
/// enough that the per-request overhead isn't most of the run.
const _defaultBatchSize = 25;
const _defaultPageSize = 100;

/// Past this a "unit" is not a thing anyone counts, and a number this far out
/// is a misread rather than a big food. Cheaper to leave the food weight-only
/// than to poison a shared catalog row.
const _maxGramsPerUnit = 10000.0;

Future<void> main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final serviceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  if (supabaseUrl == null || serviceRoleKey == null) {
    stderr.writeln('Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables first.');
    exit(1);
  }
  final anthropicKey = Platform.environment['ANTHROPIC_API_KEY'];
  if (anthropicKey == null) {
    stderr.writeln('Set ANTHROPIC_API_KEY - the converter asks Claude what one item of each food weighs.');
    exit(1);
  }

  final model = Platform.environment['ANTHROPIC_MODEL'] ?? _defaultModel;
  final maxFoods = _envInt('UNIT_MAX_FOODS');
  final batchSize = _envInt('UNIT_BATCH_SIZE') ?? _defaultBatchSize;
  final pageSize = _envInt('UNIT_PAGE_SIZE') ?? _defaultPageSize;
  // Restrict to one FoodSource.wireValue (e.g. UNIT_SOURCE=generic) so the
  // curated common foods get unit weights first (issue #206) - they start at
  // times_logged 0, so an unscoped run reaches them last. Unset = whole catalog.
  final source = Platform.environment['UNIT_SOURCE']?.trim();

  final client = http.Client();
  var countable = 0;
  var notCountable = 0;
  var unanswered = 0;

  try {
    while (maxFoods == null || countable + notCountable < maxFoods) {
      final remaining = maxFoods == null ? pageSize : maxFoods - countable - notCountable;
      // Already-answered foods drop out of the `checked_at is null` filter, so
      // the next page is just the same query again. `unanswered` is the offset
      // because those rows stay unstamped on purpose and would otherwise come
      // back forever.
      final pending = await _fetchPendingFoods(
        client,
        supabaseUrl: supabaseUrl,
        serviceRoleKey: serviceRoleKey,
        limit: remaining < pageSize ? remaining : pageSize,
        offset: unanswered,
        source: source,
      );
      if (pending.isEmpty) {
        break;
      }

      for (final batch in _batches(pending, batchSize)) {
        final conversions = await _convertBatch(client, batch: batch, apiKey: anthropicKey, model: model);
        for (final food in batch) {
          final conversion = conversions[food['id'] as String];
          if (conversion == null) {
            unanswered++;
            continue;
          }
          await _saveUnitWeight(
            client,
            supabaseUrl: supabaseUrl,
            serviceRoleKey: serviceRoleKey,
            foodId: food['id'] as String,
            gramsPerUnit: conversion.gramsPerUnit,
          );
          conversion.gramsPerUnit == null ? notCountable++ : countable++;
        }
      }
      stdout.writeln('  answered ${countable + notCountable} (countable: $countable, not countable: $notCountable)');
    }
  } on Exception catch (error) {
    // A failure that survived _send's retries. Every food is stamped as it is
    // answered, so re-running resumes rather than starting over.
    stderr.writeln('\nStopped after ${countable + notCountable} foods: $error');
    stderr.writeln('Re-run the same command to resume - already-answered foods are skipped.');
    exit(1);
  } finally {
    client.close();
  }

  stdout.writeln('Done. Countable: $countable, not countable: $notCountable, unanswered: $unanswered.');
}

Future<List<Map<String, dynamic>>> _fetchPendingFoods(
  http.Client client, {
  required String supabaseUrl,
  required String serviceRoleKey,
  required int limit,
  required int offset,
  String? source,
}) async {
  final uri = Uri.parse(
    '$supabaseUrl/rest/v1/foods'
    '?grams_per_unit_checked_at=is.null'
    '${source == null ? '' : '&source=eq.$source'}'
    '&select=id,name,brand'
    '&order=times_logged.desc'
    '&limit=$limit&offset=$offset',
  );
  final response = await _send(
    () => client.get(uri, headers: _restHeaders(serviceRoleKey)),
    description: 'fetch pending foods',
    timeout: _requestTimeout,
  );
  if (response.statusCode >= 300) {
    stderr.writeln('Failed to read foods (${response.statusCode}): ${response.body}');
    stderr.writeln('Re-run supabase/schema.sql if grams_per_unit_checked_at is missing.');
    exit(1);
  }
  return (jsonDecode(response.body) as List<dynamic>).cast<Map<String, dynamic>>();
}

/// Converts a whole batch in one request, keyed by the food's own id so a
/// response can't be silently misaligned with the batch by position - the same
/// shape tool/import_usda_foods.dart's translation uses.
///
/// A food missing from the returned map never got a usable answer, which is
/// different from the model saying it isn't countable: the caller leaves it
/// unstamped so a later run asks again. A whole batch failing (network, a
/// refusal, a rejected request) is reported the same way, one entry per food,
/// rather than aborting the run - the next page still gets processed and the
/// batch is retried by a later run.
Future<Map<String, _Conversion>> _convertBatch(
  http.Client client, {
  required List<Map<String, dynamic>> batch,
  required String apiKey,
  required String model,
}) async {
  final payload = [
    for (final food in batch) {'id': food['id'], 'name': food['name'], if (food['brand'] != null) 'brand': food['brand']},
  ];

  final http.Response response;
  try {
    response = await _send(
      () => client.post(
        Uri.parse(_anthropicUrl),
        headers: {'x-api-key': apiKey, 'anthropic-version': _anthropicVersion, 'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': model,
          'max_tokens': 8000,
          'system': _systemPrompt,
          'messages': [
            {'role': 'user', 'content': 'How much does one item of each of these foods weigh?\n${jsonEncode(payload)}'},
          ],
          'output_config': {'format': _responseFormat},
        }),
      ),
      description: 'convert ${batch.length} foods',
      timeout: _conversionTimeout,
    );
  } on Exception catch (error) {
    stderr.writeln('  could not reach the converter for ${batch.length} foods ($error)');
    return const {};
  }
  if (response.statusCode >= 300) {
    stderr.writeln('  converter rejected a batch of ${batch.length} foods (${response.statusCode}): ${response.body}');
    return const {};
  }

  final message = jsonDecode(response.body) as Map<String, dynamic>;
  // A safety refusal returns HTTP 200 with an empty content array, so the
  // stop_reason has to be checked before reading content.
  if (message['stop_reason'] == 'refusal') {
    stderr.writeln('  converter refused a batch starting at "${batch.first['name']}".');
    return const {};
  }
  final content = (message['content'] as List<dynamic>).cast<Map<String, dynamic>>();
  final text = content.firstWhere((block) => block['type'] == 'text')['text'] as String;
  final conversions = (jsonDecode(text) as Map<String, dynamic>)['conversions'] as List<dynamic>;

  return {
    for (final conversion in conversions.cast<Map<String, dynamic>>()) conversion['id'] as String: _conversionFrom(conversion),
  };
}

/// The judgement the whole feature rests on, so it is spelled out rather than
/// left to the model's instincts: what counts as one item, what is measured
/// rather than counted, and that an uncertain answer is worth less than none.
const _systemPrompt =
    'You are a nutrition database assistant. For each food you are given, decide whether a person would count it '
    'in whole items, and if so, what one typical item weighs in grams (edible portion, as the food would be logged '
    'in a food diary).\n'
    'Countable foods are the ones someone would say a number of: an egg, a banana, a slice of bread, a biscuit, '
    'a can of soda, a single-serving yogurt pot. Use the weight of one typical item of that food, not of a package '
    'holding several.\n'
    'Not countable: anything measured rather than counted - rice, flour, sugar, oil, milk, juice, ground meat, '
    'yogurt sold by weight, and any food whose serving is a spoonful, a cup or a portion rather than a number of items.\n'
    'A brand matters: "Coca-Cola 350ml lata" is countable at the weight of one can, while a plain "refrigerante" is not.\n'
    'Names may be in Portuguese or English; treat both the same.\n'
    'Confidence is "high" when you know the typical weight of that item well, "medium" when the food is clearly '
    'countable but the weight varies a lot, and "low" when you would be guessing. Prefer answering "low" over '
    'inventing a number: a wrong unit weight silently misreports macros for every user who logs the food by count.\n'
    'Return every food you were given, echoing its id back unchanged. Use gramsPerUnit 0 whenever countable is false.';

// gramsPerUnit is a plain number with 0 standing in for "no weight" rather than
// a nullable field: the structured-outputs schema subset is built around
// required, non-null properties, and `countable` already carries that meaning -
// _conversionFrom is the one place the 0 is read back as null.
const _responseFormat = {
  'type': 'json_schema',
  'schema': {
    'type': 'object',
    'properties': {
      'conversions': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'id': {'type': 'string'},
            'countable': {'type': 'boolean'},
            'gramsPerUnit': {'type': 'number'},
            'confidence': {
              'type': 'string',
              'enum': ['high', 'medium', 'low'],
            },
          },
          'required': ['id', 'countable', 'gramsPerUnit', 'confidence'],
          'additionalProperties': false,
        },
      },
    },
    'required': ['conversions'],
    'additionalProperties': false,
  },
};

/// A low-confidence guess is worth less than an empty column: the row is shared
/// by every user, and a wrong unit weight silently misreports macros for anyone
/// who logs by count. Same for a weight outside the sane range - both are
/// stamped as "asked, not countable" rather than retried forever.
_Conversion _conversionFrom(Map<String, dynamic> conversion) {
  if (conversion['countable'] != true || conversion['confidence'] == 'low') {
    return const _Conversion(gramsPerUnit: null);
  }
  final gramsPerUnit = (conversion['gramsPerUnit'] as num?)?.toDouble();
  if (gramsPerUnit == null || gramsPerUnit <= 0 || gramsPerUnit > _maxGramsPerUnit) {
    return const _Conversion(gramsPerUnit: null);
  }
  return _Conversion(gramsPerUnit: gramsPerUnit);
}

Future<void> _saveUnitWeight(
  http.Client client, {
  required String supabaseUrl,
  required String serviceRoleKey,
  required String foodId,
  required double? gramsPerUnit,
}) async {
  final response = await _send(
    () => client.patch(
      Uri.parse('$supabaseUrl/rest/v1/foods?id=eq.$foodId'),
      headers: {..._restHeaders(serviceRoleKey), 'Prefer': 'return=minimal'},
      body: jsonEncode({'grams_per_unit': gramsPerUnit, 'grams_per_unit_checked_at': DateTime.now().toUtc().toIso8601String()}),
    ),
    description: 'save unit weight for $foodId',
    timeout: _requestTimeout,
  );
  if (response.statusCode >= 300) {
    // Fail the whole run rather than logging and moving on: a rejected write
    // means every write after it is rejected the same way (a missing column, a
    // check constraint, a bad key), and continuing would print a reassuring
    // "Done" over a catalog that never changed.
    stderr.writeln('Failed to save unit weight (${response.statusCode}): ${response.body}');
    stderr.writeln('Nothing after this food was saved. Re-run supabase/schema.sql if a column is missing.');
    exit(1);
  }
}

Iterable<List<T>> _batches<T>(List<T> items, int size) sync* {
  for (var start = 0; start < items.length; start += size) {
    yield items.sublist(start, (start + size).clamp(0, items.length));
  }
}

/// Every outbound call goes through here, for the reasons
/// tool/import_exercise_catalog.dart's copy documents: a timeout (package:http
/// waits forever, and a stalled connection otherwise hangs the run with no
/// output), plus a retry with backoff on the failures worth retrying. A 4xx
/// other than 429 is returned as-is - it will fail identically on every try.
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

Map<String, String> _restHeaders(String serviceRoleKey) => {
  'apikey': serviceRoleKey,
  'Authorization': 'Bearer $serviceRoleKey',
  'Content-Type': 'application/json',
};

int? _envInt(String key) {
  final raw = Platform.environment[key];
  return raw == null ? null : int.tryParse(raw.trim());
}

/// A resolved answer. A null [gramsPerUnit] is the converter saying the food
/// isn't countable, which is a real answer worth stamping - unlike a food the
/// converter never answered for, which [_convertBatch] reports by leaving out
/// of its map.
class _Conversion {
  const _Conversion({required this.gramsPerUnit});

  final double? gramsPerUnit;
}
