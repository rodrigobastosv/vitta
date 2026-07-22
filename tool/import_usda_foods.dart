// One-time/occasional import of curated generic whole foods into the shared
// `foods` catalog as source 'generic' (see supabase/schema.sql and issue #180).
//
// Open Food Facts is a barcode database of packaged products, so simple foods
// like a raw banana, plain rice or an egg were either absent from the catalog
// or buried under dozens of brands. USDA FoodData Central's Foundation Foods and
// SR Legacy datasets are the public-domain, per-100g canonical source for
// exactly those foods, so this seeds them as barcode-less 'generic' rows, which
// SupabaseDietDataSource.searchCatalog ranks above every other source.
//
// Names are translated to Brazilian Portuguese by default (foods.name is a
// single-language column, unlike the exercise catalog's locale-keyed jsonb, and
// the primary audience is Brazil), reusing the same Anthropic call the exercise
// importer does. The row id is derived from the USDA fdcId *and* the locale, so
// running once per locale seeds an "Arroz" and a "Rice" copy that coexist (the
// catalog already carries multilingual rows from OFF) and a re-run upserts in
// place rather than duplicating.
//
// Download the datasets once (JSON, "Foundation Foods" and "SR Legacy" from
// https://fdc.nal.usda.gov/download-datasets.html) and point the tool at them:
//   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... ANTHROPIC_API_KEY=... \
//   USDA_JSON_PATHS=foundationDownload.json,FoodData_Central_sr_legacy_food_json.json \
//   dart run tool/import_usda_foods.dart
//
// SUPABASE_SERVICE_ROLE_KEY bypasses RLS - never put it in .env (flutter_dotenv
// loads that file into the shipped app) or commit it. Pass it as a one-off shell
// environment variable only. Requires supabase/schema.sql to have been re-run
// first (the source check must allow 'generic').
//
// Optional env vars:
//   USDA_LOCALE=pt                     name language (pt translates, en keeps USDA)
//   IMPORT_TRANSLATE=true              set false to skip translation for a pt run
//   IMPORT_MAX_FOODS=...               stop after ~N imported (default: all)
//   IMPORT_BATCH_SIZE=40               foods per upsert / translation request
//   ANTHROPIC_MODEL=claude-opus-4-8    model used for the translation

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:vitta/app/domain/diet/entities/food_source.dart';

const _anthropicUrl = 'https://api.anthropic.com/v1/messages';
const _anthropicVersion = '2023-06-01';
const _defaultModel = 'claude-opus-4-8';
const _defaultBatchSize = 40;
const _requestTimeout = Duration(seconds: 45);
const _translationTimeout = Duration(minutes: 5);
const _maxAttempts = 4;

// USDA nutrient "number" -> the per-100g field it fills. Foundation Foods and SR
// Legacy report these amounts per 100g already, the same base as foods.*_per_100g.
// Energy has three numbers, all in kcal: '208' is the classic Energy value, but
// most Foundation Foods only carry the Atwater ones ('958' specific factors,
// '957' general) - preferring 208, then the more precise specific, then general
// is what keeps ~320 of 360 foods instead of the ~95 that report 208.
const _energyNumbers = ['208', '958', '957'];
const _proteinNumber = '203';
const _carbsNumber = '205';
const _fatNumber = '204';
const _fiberNumber = '291';

// USDA's own food category -> FoodCategory.wireValue (see
// lib/app/domain/diet/entities/food_category.dart and issue #206). Covers the
// SR Legacy taxonomy too, so the same map works for both downloads; an unlisted
// or mixed category (Restaurant Foods, Snacks, Baby Foods) maps to no category
// and the app just shows the default placeholder for it.
const _categoryWireValues = {
  'Fruits and Fruit Juices': 'fruit',
  'Vegetables and Vegetable Products': 'vegetable',
  'Cereal Grains and Pasta': 'grain',
  'Baked Products': 'grain',
  'Breakfast Cereals': 'grain',
  'Beef Products': 'protein',
  'Pork Products': 'protein',
  'Poultry Products': 'protein',
  'Lamb, Veal, and Game Products': 'protein',
  'Finfish and Shellfish Products': 'protein',
  'Sausages and Luncheon Meats': 'protein',
  'Dairy and Egg Products': 'dairy_egg',
  'Legumes and Legume Products': 'legume_nut',
  'Nut and Seed Products': 'legume_nut',
  'Fats and Oils': 'fat_oil',
  'Beverages': 'beverage',
  'Sweets': 'sweet',
  'Spices and Herbs': 'condiment',
  'Soups, Sauces, and Gravies': 'condiment',
};

Future<void> main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final serviceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  if (supabaseUrl == null || serviceRoleKey == null) {
    stderr.writeln('Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables first.');
    exit(1);
  }

  final jsonPaths = _jsonPathsFromEnv();
  if (jsonPaths.isEmpty) {
    stderr.writeln('Set USDA_JSON_PATHS to one or more downloaded FoodData Central JSON files (comma-separated).');
    exit(1);
  }

  final locale = (Platform.environment['USDA_LOCALE'] ?? 'pt').trim().toLowerCase();
  final translate = locale != 'en' && Platform.environment['IMPORT_TRANSLATE'] != 'false';
  final anthropicKey = Platform.environment['ANTHROPIC_API_KEY'];
  if (translate && anthropicKey == null) {
    stderr.writeln('Set ANTHROPIC_API_KEY to translate names to "$locale", or IMPORT_TRANSLATE=false to keep the USDA English names.');
    exit(1);
  }
  final model = Platform.environment['ANTHROPIC_MODEL'] ?? _defaultModel;
  final batchSize = _envInt('IMPORT_BATCH_SIZE') ?? _defaultBatchSize;
  final maxFoods = _envInt('IMPORT_MAX_FOODS');

  final foods = _readFoods(jsonPaths);
  final capped = maxFoods == null ? foods : foods.take(maxFoods).toList();
  stdout.writeln('Read ${foods.length} usable foods (locale: $locale, translate: $translate)${maxFoods == null ? '' : ', capping at $maxFoods'}.');

  final client = http.Client();
  var imported = 0;
  try {
    for (var start = 0; start < capped.length; start += batchSize) {
      final batch = capped.sublist(start, (start + batchSize).clamp(0, capped.length));
      final translations = translate ? await _translateBatch(client, batch: batch, apiKey: anthropicKey!, model: model) : const <int, String>{};
      final rows = [
        for (final food in batch) _toFoodRow(food, locale: locale, translatedName: translations[food.fdcId]),
      ];
      await _upsertRows(client, supabaseUrl: supabaseUrl, serviceRoleKey: serviceRoleKey, rows: rows);
      imported += rows.length;
      stdout.writeln('  imported $imported/${capped.length}');
    }
  } finally {
    client.close();
  }

  stdout.writeln('Done. Imported $imported generic foods.');
}

List<String> _jsonPathsFromEnv() {
  final raw = Platform.environment['USDA_JSON_PATHS'];
  if (raw == null) {
    return const [];
  }
  return raw.split(',').map((path) => path.trim()).where((path) => path.isNotEmpty).toList();
}

// FoodData Central JSON wraps the food list in a single top-level key
// ("FoundationFoods" or "SRLegacyFoods"); some exports are a bare array. Take
// the first List value either way, so a new dataset name needs no code change.
List<_UsdaFood> _readFoods(List<String> jsonPaths) {
  final foods = <_UsdaFood>[];
  final seenFdcIds = <int>{};
  for (final path in jsonPaths) {
    final decoded = jsonDecode(File(path).readAsStringSync());
    final rawFoods = switch (decoded) {
      final List<dynamic> list => list,
      final Map<String, dynamic> map => map.values.whereType<List<dynamic>>().firstWhere((_) => true, orElse: () => const []),
      _ => const <dynamic>[],
    };
    // USDA's export peppers the food array with literal `null` entries (32 of
    // 395 in the Foundation download), so whereType skips them and any stray
    // non-object rather than a .cast that throws on the first null.
    for (final rawFood in rawFoods.whereType<Map<String, dynamic>>()) {
      final food = _UsdaFood.fromJson(rawFood);
      if (food != null && seenFdcIds.add(food.fdcId)) {
        foods.add(food);
      }
    }
  }
  return foods;
}

Map<String, dynamic> _toFoodRow(_UsdaFood food, {required String locale, required String? translatedName}) => {
  // A deterministic UUID (valid version-4 layout) keyed on fdcId + locale: a
  // re-run upserts the same row rather than duplicating, and the en/pt copies of
  // one food get distinct ids so they can coexist. user_id is intentionally
  // omitted, not null: on insert it falls back to the null default (generic rows
  // are unowned) and on the id DO UPDATE an absent column is left untouched, the
  // same reasoning import_food_catalog.dart documents.
  'id': _rowId(food.fdcId, locale),
  'name': translatedName ?? food.description,
  'source': FoodSource.generic.wireValue,
  'calories_per_100g': food.calories,
  'protein_per_100g': food.protein,
  'carbs_per_100g': food.carbs,
  'fat_per_100g': food.fat,
  'fiber_per_100g': food.fiber ?? 0,
  'category': food.category,
};

String _rowId(int fdcId, String locale) {
  final localeSegment = locale == 'en' ? '00000000' : '00000001';
  final fdc = fdcId.toRadixString(16).padLeft(12, '0');
  return '$localeSegment-0000-4000-8000-$fdc';
}

// Translates a batch in one request, keyed by fdcId so a response can't be
// silently misaligned with the batch by position. Structured outputs guarantee
// the shape, so the parse below needs no fallbacks - the same shape and safety
// checks import_exercise_catalog.dart uses.
Future<Map<int, String>> _translateBatch(
  http.Client client, {
  required List<_UsdaFood> batch,
  required String apiKey,
  required String model,
}) async {
  final payload = [
    for (final food in batch) {'fdcId': food.fdcId, 'name': food.description},
  ];

  final response = await _send(
    () => client.post(
      Uri.parse(_anthropicUrl),
      headers: {'x-api-key': apiKey, 'anthropic-version': _anthropicVersion, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': model,
        'max_tokens': 8000,
        'system':
            'You translate common food names from English to Brazilian Portuguese. '
            'Use the everyday term a Brazilian would use and write at the supermarket or in a food diary '
            '(e.g. "Rice, white, long-grain, cooked" is "Arroz branco cozido", "Chicken, broilers or fryers, breast, raw" '
            'is "Peito de frango cru", "Egg, whole, raw, fresh" is "Ovo de galinha cru"). Keep it concise and natural, '
            'dropping USDA cataloguing qualifiers that a person would not say. '
            'Return every food you were given, echoing its fdcId back unchanged.',
        'messages': [
          {'role': 'user', 'content': 'Translate these foods:\n${jsonEncode(payload)}'},
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
                      'fdcId': {'type': 'integer'},
                      'name': {'type': 'string'},
                    },
                    'required': ['fdcId', 'name'],
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
    stderr.writeln('Translation refused for batch starting at fdcId ${batch.first.fdcId}.');
    exit(1);
  }
  final content = (message['content'] as List<dynamic>).cast<Map<String, dynamic>>();
  final text = content.firstWhere((block) => block['type'] == 'text')['text'] as String;
  final translations = (jsonDecode(text) as Map<String, dynamic>)['translations'] as List<dynamic>;

  return {
    for (final translation in translations.cast<Map<String, dynamic>>()) translation['fdcId'] as int: translation['name'] as String,
  };
}

Future<void> _upsertRows(
  http.Client client, {
  required String supabaseUrl,
  required String serviceRoleKey,
  required List<Map<String, dynamic>> rows,
}) async {
  final uri = Uri.parse('$supabaseUrl/rest/v1/foods?on_conflict=id');
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
    // means every batch after it is rejected the same way (a missing 'generic'
    // in the source check, a bad column), and continuing would print a
    // reassuring "Done" while nothing was imported.
    stderr.writeln('Upsert failed (${response.statusCode}): ${response.body}');
    stderr.writeln('Nothing after this batch was imported. Re-run supabase/schema.sql if the source check does not allow "generic".');
    exit(1);
  }
}

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

class _UsdaFood {
  _UsdaFood({
    required this.fdcId,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.category,
  });

  // Keeps only foods with the four mandatory macros: fiber is optional (defaults
  // to 0 downstream, like the OFF import), the macros are check-constrained not-null.
  static _UsdaFood? fromJson(Map<String, dynamic> json) {
    final fdcId = json['fdcId'];
    final description = json['description'] as String?;
    if (fdcId is! int || description == null || description.isEmpty) {
      return null;
    }
    final amounts = _amountsByNutrientNumber(json['foodNutrients']);
    final calories = _energyNumbers.map((number) => amounts[number]).nonNulls.firstOrNull;
    final protein = amounts[_proteinNumber];
    final carbs = amounts[_carbsNumber];
    final fat = amounts[_fatNumber];
    if (calories == null || protein == null || carbs == null || fat == null) {
      return null;
    }
    return _UsdaFood(
      fdcId: fdcId,
      description: description,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: amounts[_fiberNumber],
      category: _categoryWireValues[_categoryDescription(json['foodCategory'])],
    );
  }

  // foodCategory is an object ({description: ...}) in the Foundation/SR Legacy
  // downloads, but a bare string in some exports - handle both.
  static String? _categoryDescription(dynamic rawCategory) => switch (rawCategory) {
    final Map<String, dynamic> map => map['description'] as String?,
    final String description => description,
    _ => null,
  };

  static Map<String, double> _amountsByNutrientNumber(dynamic rawNutrients) {
    if (rawNutrients is! List) {
      return const {};
    }
    final amounts = <String, double>{};
    for (final rawNutrient in rawNutrients.whereType<Map<String, dynamic>>()) {
      final number = (rawNutrient['nutrient'] as Map<String, dynamic>?)?['number'];
      final amount = rawNutrient['amount'];
      if (number is String && amount is num) {
        amounts[number] = amount.toDouble();
      }
    }
    return amounts;
  }

  final int fdcId;
  final String description;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final String? category;
}
