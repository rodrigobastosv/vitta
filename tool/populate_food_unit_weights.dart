// Populates `foods.grams_per_unit` so a countable food can be logged as
// "2 eggs" instead of "100 g" (see issue #114 and supabase/schema.sql).
//
//   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... \
//   dart run tool/populate_food_unit_weights.dart
//
// It asks the food-gram-converter API (https://food-gram-converter.onrender.com/docs)
// what one whole item of each food weighs. The API answers with a weight for a
// countable food ("um ovo tipico pesa cerca de 50 g") and `not_convertible` for
// anything measured rather than counted - rice is a bulk grain, milk is a
// liquid. That verdict is the reason this can't be read off Open Food Facts'
// own product_quantity instead: a 1kg bag of rice has a product_quantity, and
// believing it would make rice countable at 1000g per unit.
//
// Safe to re-run, and that is what `grams_per_unit_checked_at` is for: every
// answer stamps it, so a re-run only asks about foods nobody has asked about
// yet. Without it a null grams_per_unit would mean both "not countable" and
// "not asked", and every run would re-ask an LLM about every bulk food forever.
// A food the converter couldn't be reached for is left unstamped, so the next
// run picks it up.
//
// Foods are processed most-logged-first (foods.times_logged), so a bounded run
// still covers what users actually eat. UNIT_MAX_FOODS is the way to try it
// against a handful of rows before paying for the whole catalog.
//
// SUPABASE_SERVICE_ROLE_KEY bypasses RLS - never put it in .env (flutter_dotenv
// loads that file into the shipped app) or commit it anywhere. Pass it as a
// one-off shell environment variable only.
//
// Requires supabase/schema.sql to have been re-run first (foods.grams_per_unit
// and foods.grams_per_unit_checked_at must exist).
//
// Optional env vars:
//   CONVERTER_URL=...      converter API base (default the public deployment)
//   UNIT_MAX_FOODS=...     stop after N foods (default: the whole catalog)
//   UNIT_CONCURRENCY=4     foods asked about at once
//   UNIT_PAGE_SIZE=100     foods fetched per query

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _converterUrl = 'https://food-gram-converter.onrender.com';
const _requestTimeout = Duration(seconds: 45);

/// The converter is an LLM behind a free-tier host that cold-starts, so the
/// first call of a run can take far longer than any Supabase call.
const _converterTimeout = Duration(minutes: 2);
const _maxAttempts = 4;
const _defaultConcurrency = 4;
const _defaultPageSize = 100;

/// The API caps `description` at 200 characters and 422s past it.
const _maxDescriptionLength = 200;

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

  final converterUrl = Platform.environment['CONVERTER_URL'] ?? _converterUrl;
  final maxFoods = _envInt('UNIT_MAX_FOODS');
  final concurrency = _envInt('UNIT_CONCURRENCY') ?? _defaultConcurrency;
  final pageSize = _envInt('UNIT_PAGE_SIZE') ?? _defaultPageSize;

  final client = http.Client();
  var countable = 0;
  var notCountable = 0;
  var unreachable = 0;

  try {
    while (maxFoods == null || countable + notCountable < maxFoods) {
      final remaining = maxFoods == null ? pageSize : maxFoods - countable - notCountable;
      // Already-answered foods drop out of the `checked_at is null` filter, so
      // the next page is just the same query again. `unreachable` is the offset
      // because those rows stay unstamped on purpose and would otherwise come
      // back forever.
      final pending = await _fetchPendingFoods(
        client,
        supabaseUrl: supabaseUrl,
        serviceRoleKey: serviceRoleKey,
        limit: remaining < pageSize ? remaining : pageSize,
        offset: unreachable,
      );
      if (pending.isEmpty) {
        break;
      }

      for (final batch in _batches(pending, concurrency)) {
        final conversions = await Future.wait(batch.map((food) => _convert(client, converterUrl: converterUrl, food: food)));
        for (final (index, conversion) in conversions.indexed) {
          if (conversion == null) {
            unreachable++;
            continue;
          }
          await _saveUnitWeight(
            client,
            supabaseUrl: supabaseUrl,
            serviceRoleKey: serviceRoleKey,
            foodId: batch[index]['id'] as String,
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

  stdout.writeln('Done. Countable: $countable, not countable: $notCountable, unreachable: $unreachable.');
}

Future<List<Map<String, dynamic>>> _fetchPendingFoods(
  http.Client client, {
  required String supabaseUrl,
  required String serviceRoleKey,
  required int limit,
  required int offset,
}) async {
  final uri = Uri.parse(
    '$supabaseUrl/rest/v1/foods'
    '?grams_per_unit_checked_at=is.null'
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

/// Null means the converter never gave a usable answer, which is different from
/// it saying the food isn't countable - the food stays unstamped so a later run
/// asks again.
Future<_Conversion?> _convert(http.Client client, {required String converterUrl, required Map<String, dynamic> food}) async {
  final description = _describe(food);
  if (description.isEmpty) {
    return null;
  }
  final http.Response response;
  try {
    response = await _send(
      () => client.post(
        Uri.parse('$converterUrl/convert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'description': description, 'quantity': 1}),
      ),
      description: 'convert "$description"',
      timeout: _converterTimeout,
    );
  } on Exception catch (error) {
    stderr.writeln('  could not reach the converter for "$description" ($error)');
    return null;
  }
  if (response.statusCode >= 300) {
    stderr.writeln('  converter rejected "$description" (${response.statusCode})');
    return null;
  }

  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (body['status'] != 'converted') {
    return const _Conversion(gramsPerUnit: null);
  }
  // A low-confidence guess is worth less than an empty column: the row is
  // shared by every user, and a wrong unit weight silently misreports macros
  // for anyone who logs by count.
  if (body['confidence'] == 'low') {
    return const _Conversion(gramsPerUnit: null);
  }
  final gramsPerUnit = (body['grams_per_unit'] as num?)?.toDouble();
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

/// What the converter is asked about. The brand matters - "Coca-Cola 350ml
/// lata" is countable in a way "refrigerante" is not.
String _describe(Map<String, dynamic> food) {
  final name = (food['name'] as String? ?? '').trim();
  final brand = (food['brand'] as String? ?? '').trim();
  final description = brand.isEmpty ? name : '$name $brand';
  return description.length <= _maxDescriptionLength ? description : description.substring(0, _maxDescriptionLength);
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
/// isn't countable, which is a real answer worth stamping - unlike a failure to
/// reach it at all, which [_convert] reports as a null `_Conversion`.
class _Conversion {
  const _Conversion({required this.gramsPerUnit});

  final double? gramsPerUnit;
}
