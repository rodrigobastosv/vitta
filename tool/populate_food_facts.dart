// Fills the three facts the catalog can't read off a nutrition label - how a
// food is *measured* and whether its numbers are raw or cooked:
//
//   foods.grams_per_unit    what one whole item weighs, so "2 eggs" can be
//                           logged instead of "100 g" (issue #114)
//   foods.density_g_per_ml  what one mL weighs, so a drink can be logged in mL
//                           instead of grams (issue #253)
//   foods.preparation       whether the per-100g macros describe the food raw or
//                           cooked (issue #253)
//
//   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... ANTHROPIC_API_KEY=... \
//   dart run tool/populate_food_facts.dart
//
// The three are asked together in one batched request per page, because they are
// one judgement about the food rather than three: whether you count it, pour it
// or weigh it, and whether it has been cooked, are all answered by knowing what
// the food is. Asking separately would triple the requests and let the answers
// disagree with each other.
//
// The converter is ours (issue #211): it asks Claude directly with structured
// outputs, the same call tool/import_usda_foods.dart uses to translate names. It
// replaced a public food-gram-converter API that cold-started, rate-limited,
// answered one food per request and could disappear without notice.
//
// The judgement asked for is the whole feature, so it is spelled out in
// _systemPrompt rather than left to instinct: a countable food gets a weight
// ("um ovo tipico pesa cerca de 50 g") while anything measured comes back not
// countable; a drink gets a density while a solid does not; and a low-confidence
// answer is discarded, because a wrong number silently misreports macros for
// every user who logs the food. That verdict is why none of this can be read off
// Open Food Facts' own product_quantity: a 1kg bag of rice has one too, and
// believing it would make rice countable at 1000g per unit.
//
// Safe to re-run, and that is what `catalog_facts_checked_at` is for: every
// answer stamps it, so a re-run only asks about foods nobody has asked about
// yet. Without it a null grams_per_unit or density_g_per_ml would mean both "not
// applicable" and "not asked", and every run would re-ask about every bulk food
// forever. A food the model didn't answer for is left unstamped, so the next run
// picks it up.
//
// Foods are processed most-logged-first (foods.times_logged), so a bounded run
// still covers what users actually eat. FACTS_MAX_FOODS is the way to try it
// against a handful of rows before paying for the whole catalog, and
// FACTS_DRY_RUN=true prints the verdicts without writing any of them.
//
// SUPABASE_SERVICE_ROLE_KEY bypasses RLS - never put it in .env (flutter_dotenv
// loads that file into the shipped app) or commit it anywhere. Pass it (and
// ANTHROPIC_API_KEY) as a one-off shell environment variable only.
//
// Requires supabase/schema.sql to have been re-run first (foods.density_g_per_ml,
// foods.preparation and foods.catalog_facts_checked_at must exist).
//
// Optional env vars:
//   FACTS_MAX_FOODS=...             stop after N foods (default: the whole catalog)
//   FACTS_SOURCE=generic            only ask about one FoodSource (default: every source)
//   FACTS_BATCH_SIZE=25             foods asked about per request
//   FACTS_PAGE_SIZE=100             foods fetched per query
//   FACTS_DRY_RUN=true              print what would be written, write nothing
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

/// Mirrors the `density_g_per_ml <= 2` check in supabase/schema.sql: honey, the
/// densest thing in a food diary, is ~1.42, so anything past 2 is a misread. The
/// floor rules out a number given in the wrong unit (kg/L, or grams per litre).
const _minDensityGPerMl = 0.5;
const _maxDensityGPerMl = 2.0;

const _preparationValues = {'raw', 'cooked'};

Future<void> main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final serviceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  if (supabaseUrl == null || serviceRoleKey == null) {
    stderr.writeln('Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables first.');
    exit(1);
  }
  final anthropicKey = Platform.environment['ANTHROPIC_API_KEY'];
  if (anthropicKey == null) {
    stderr.writeln('Set ANTHROPIC_API_KEY - the converter asks Claude how each food is measured.');
    exit(1);
  }

  final model = Platform.environment['ANTHROPIC_MODEL'] ?? _defaultModel;
  final maxFoods = _envInt('FACTS_MAX_FOODS');
  final batchSize = _envInt('FACTS_BATCH_SIZE') ?? _defaultBatchSize;
  final pageSize = _envInt('FACTS_PAGE_SIZE') ?? _defaultPageSize;
  final isDryRun = Platform.environment['FACTS_DRY_RUN'] == 'true';
  // Restrict to one FoodSource.wireValue (e.g. FACTS_SOURCE=generic) so the
  // curated common foods get answered first (issue #206) - they start at
  // times_logged 0, so an unscoped run reaches them last. Unset = whole catalog.
  final source = Platform.environment['FACTS_SOURCE']?.trim();

  final client = http.Client();
  final tally = _Tally();

  try {
    while (maxFoods == null || tally.answered < maxFoods) {
      final remaining = maxFoods == null ? pageSize : maxFoods - tally.answered;
      // Already-answered foods drop out of the `checked_at is null` filter, so
      // the next page is just the same query again. `unanswered` is the offset
      // because those rows stay unstamped on purpose and would otherwise come
      // back forever. A dry run stamps nothing, so there the offset has to count
      // every row seen or the first page repeats forever.
      final pending = await _fetchPendingFoods(
        client,
        supabaseUrl: supabaseUrl,
        serviceRoleKey: serviceRoleKey,
        limit: remaining < pageSize ? remaining : pageSize,
        offset: isDryRun ? tally.answered + tally.unanswered : tally.unanswered,
        source: source,
      );
      if (pending.isEmpty) {
        break;
      }

      for (final batch in _batches(pending, batchSize)) {
        final facts = await _resolveBatch(client, batch: batch, apiKey: anthropicKey, model: model);
        for (final food in batch) {
          final resolved = facts[food['id'] as String];
          if (resolved == null) {
            tally.unanswered++;
            continue;
          }
          if (isDryRun) {
            stdout.writeln('  would set ${food['name']}: $resolved');
          } else {
            await _saveFacts(
              client,
              supabaseUrl: supabaseUrl,
              serviceRoleKey: serviceRoleKey,
              foodId: food['id'] as String,
              facts: resolved,
            );
          }
          tally.count(resolved);
        }
      }
      stdout.writeln('  $tally');
    }
  } on Exception catch (error) {
    // A failure that survived _send's retries. Every food is stamped as it is
    // answered, so re-running resumes rather than starting over.
    stderr.writeln('\nStopped after ${tally.answered} foods: $error');
    stderr.writeln('Re-run the same command to resume - already-answered foods are skipped.');
    exit(1);
  } finally {
    client.close();
  }

  stdout.writeln('Done${isDryRun ? ' (dry run, nothing written)' : ''}. $tally');
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
    '?catalog_facts_checked_at=is.null'
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
    stderr.writeln('Re-run supabase/schema.sql if catalog_facts_checked_at is missing.');
    exit(1);
  }
  return (jsonDecode(response.body) as List<dynamic>).cast<Map<String, dynamic>>();
}

/// Resolves a whole batch in one request, keyed by the food's own id so a
/// response can't be silently misaligned with the batch by position - the same
/// shape tool/import_usda_foods.dart's translation uses.
///
/// A food missing from the returned map never got a usable answer, which is
/// different from the model saying nothing applies to it: the caller leaves it
/// unstamped so a later run asks again. A whole batch failing (network, a
/// refusal, a rejected request) is reported the same way, one entry per food,
/// rather than aborting the run - the next page still gets processed and the
/// batch is retried by a later run.
Future<Map<String, _FoodFacts>> _resolveBatch(
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
          'max_tokens': 16000,
          'system': _systemPrompt,
          'messages': [
            {'role': 'user', 'content': 'How is each of these foods measured, and are its numbers raw or cooked?\n${jsonEncode(payload)}'},
          ],
          'output_config': {'format': _responseFormat},
        }),
      ),
      description: 'resolve ${batch.length} foods',
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
  final resolved = (jsonDecode(text) as Map<String, dynamic>)['foods'] as List<dynamic>;

  return {for (final food in resolved.cast<Map<String, dynamic>>()) food['id'] as String: _factsFrom(food)};
}

const _systemPrompt =
    'You are a nutrition database assistant. For each food you are given, answer three things about how it would be '
    'logged in a food diary.\n'
    '\n'
    '1. COUNTABLE. Would a person count this food in whole items, and if so, what does one typical item weigh in '
    'grams (edible portion)? Countable foods are the ones someone would say a number of: an egg, a banana, a slice '
    'of bread, a biscuit, a can of soda, a single-serving yogurt pot. Use the weight of one typical item, not of a '
    'package holding several. Not countable: anything measured rather than counted - rice, flour, sugar, oil, milk '
    'sold by the bottle, ground meat, yogurt sold by weight, and any food whose serving is a spoonful, a cup or a '
    'portion rather than a number of items. A brand matters: "Coca-Cola 350ml lata" is countable at the weight of '
    'one can, while a plain "refrigerante" is not.\n'
    '\n'
    '2. LIQUID. Would a person measure this food in millilitres rather than weighing it? That is true of drinks and '
    'pourable liquids - milk, juice, soda, coffee, beer, broth, cooking oil - and false of everything you would put '
    'on a scale, including thick foods like yogurt, honey or peanut butter that are sold by weight. If it is a '
    'liquid, give its density in grams per millilitre: water and most juices are about 1.0, milk about 1.03, a '
    'sugary soda about 1.04, spirits about 0.95, vegetable oil about 0.92. A food can be both countable and liquid '
    '(a 350 mL can of soda is both). If the name states a package size in grams or kilograms rather than in '
    'millilitres or litres, that food is sold by weight and is NOT a liquid, however pourable it is - a "1,15KG" tub '
    'of drinking yogurt is weighed, a "1L" carton of the same yogurt is poured.\n'
    '\n'
    "3. PREPARATION. Do this food's nutrition numbers describe it raw or cooked? Answer \"raw\" or \"cooked\" only "
    'when the food genuinely has both states and the name says which one it is ("Arroz branco cozido" is cooked, '
    '"Peito de frango cru" is raw). Answer "unstated" for anything with no meaningful raw/cooked distinction - a soft '
    'drink, an apple, milk, a biscuit, a protein powder - and for a food whose name does not say which it is. Do not '
    'guess: labelling cooked rice as raw would triple its calories for everyone who logs it.\n'
    '\n'
    'Names may be in Portuguese or English; treat both the same.\n'
    'Confidence is "high" when you know this food well, "medium" when the answer is clear but the numbers vary a '
    'lot, and "low" when you would be guessing. Prefer answering "low" over inventing a number: a wrong unit weight '
    'or density silently misreports macros for every user who logs the food.\n'
    'Return every food you were given, echoing its id back unchanged. Use gramsPerUnit 0 whenever countable is '
    'false, and densityGramsPerMl 0 whenever liquid is false.';

// gramsPerUnit and densityGramsPerMl are plain numbers with 0 standing in for
// "not applicable" rather than nullable fields: the structured-outputs schema
// subset is built around required, non-null properties, and the sibling
// `countable`/`liquid` booleans already carry that meaning - _factsFrom is the
// one place the 0 is read back as null. `preparation` has an explicit 'unstated'
// case for the same reason.
const _responseFormat = {
  'type': 'json_schema',
  'schema': {
    'type': 'object',
    'properties': {
      'foods': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'id': {'type': 'string'},
            'countable': {'type': 'boolean'},
            'gramsPerUnit': {'type': 'number'},
            'liquid': {'type': 'boolean'},
            'densityGramsPerMl': {'type': 'number'},
            'preparation': {
              'type': 'string',
              'enum': ['raw', 'cooked', 'unstated'],
            },
            'confidence': {
              'type': 'string',
              'enum': ['high', 'medium', 'low'],
            },
          },
          'required': ['id', 'countable', 'gramsPerUnit', 'liquid', 'densityGramsPerMl', 'preparation', 'confidence'],
          'additionalProperties': false,
        },
      },
    },
    'required': ['foods'],
    'additionalProperties': false,
  },
};

/// A low-confidence guess is worth less than an empty column: the row is shared
/// by every user, and a wrong unit weight or density silently misreports macros
/// for anyone who logs by count or by volume. Same for a number outside the sane
/// range. Either way the row is stamped as "asked, nothing applies" rather than
/// retried forever.
///
/// The confidence gate drops the measures but *keeps* the preparation, because
/// the two are not the same kind of claim: a preparation is read off the food's
/// own name ("cozido"), so being unsure what one item of it weighs says nothing
/// about it.
_FoodFacts _factsFrom(Map<String, dynamic> food) {
  final isConfident = food['confidence'] != 'low';
  return _FoodFacts(
    gramsPerUnit: food['countable'] == true && isConfident ? _inRange(food['gramsPerUnit'], min: 0, max: _maxGramsPerUnit) : null,
    densityGPerMl: food['liquid'] == true && isConfident
        ? _inRange(food['densityGramsPerMl'], min: _minDensityGPerMl, max: _maxDensityGPerMl)
        : null,
    preparation: _preparationValues.contains(food['preparation']) ? food['preparation'] as String : null,
  );
}

double? _inRange(dynamic raw, {required double min, required double max}) {
  final value = (raw as num?)?.toDouble();
  return value == null || value <= min || value > max ? null : value;
}

Future<void> _saveFacts(
  http.Client client, {
  required String supabaseUrl,
  required String serviceRoleKey,
  required String foodId,
  required _FoodFacts facts,
}) async {
  final response = await _send(
    () => client.patch(
      Uri.parse('$supabaseUrl/rest/v1/foods?id=eq.$foodId'),
      headers: {..._restHeaders(serviceRoleKey), 'Prefer': 'return=minimal'},
      body: jsonEncode({
        'grams_per_unit': facts.gramsPerUnit,
        'density_g_per_ml': facts.densityGPerMl,
        'preparation': facts.preparation,
        'catalog_facts_checked_at': DateTime.now().toUtc().toIso8601String(),
      }),
    ),
    description: 'save facts for $foodId',
    timeout: _requestTimeout,
  );
  if (response.statusCode >= 300) {
    // Fail the whole run rather than logging and moving on: a rejected write
    // means every write after it is rejected the same way (a missing column, a
    // check constraint, a bad key), and continuing would print a reassuring
    // "Done" over a catalog that never changed.
    stderr.writeln('Failed to save food facts (${response.statusCode}): ${response.body}');
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

/// A resolved answer. A null field is the converter saying that measure doesn't
/// apply to this food, which is a real answer worth stamping - unlike a food the
/// converter never answered for, which [_resolveBatch] reports by leaving out of
/// its map.
class _FoodFacts {
  const _FoodFacts({required this.gramsPerUnit, required this.densityGPerMl, required this.preparation});

  final double? gramsPerUnit;
  final double? densityGPerMl;
  final String? preparation;

  bool get isEmpty => gramsPerUnit == null && densityGPerMl == null && preparation == null;

  @override
  String toString() => isEmpty
      ? 'nothing applies'
      : [
          if (gramsPerUnit case final gramsPerUnit?) '${gramsPerUnit}g/un',
          if (densityGPerMl case final densityGPerMl?) '${densityGPerMl}g/mL',
          ?preparation,
        ].join(' ');
}

/// Deliberately not mutually exclusive except for [nothing]: a can of soda is
/// both countable and a liquid, and the point of the tally is to see whether each
/// fact is actually being filled.
class _Tally {
  int countable = 0;
  int liquid = 0;
  int prepared = 0;
  int nothing = 0;
  int unanswered = 0;

  int answered = 0;

  void count(_FoodFacts facts) {
    answered++;
    if (facts.gramsPerUnit != null) {
      countable++;
    }
    if (facts.densityGPerMl != null) {
      liquid++;
    }
    if (facts.preparation != null) {
      prepared++;
    }
    if (facts.isEmpty) {
      nothing++;
    }
  }

  @override
  String toString() =>
      'answered $answered (countable: $countable, liquid: $liquid, raw/cooked: $prepared, nothing: $nothing, unanswered: $unanswered)';
}
