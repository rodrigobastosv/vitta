// Reports what is wrong with the shared `foods` catalog, and optionally fixes
// the one class of problem that is safe to fix automatically (issue #253).
//
//   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... dart run tool/audit_food_catalog.dart
//
// It asks four questions, all of which the catalog answers about itself - no LLM,
// no cost, safe to run as often as you like:
//
//   COVERAGE     how many rows carry a category, a unit weight, a density, a
//                raw/cooked state - i.e. where tool/populate_food_facts.dart
//                still has work to do
//   DUPLICATES   rows whose names are the same once case, accents and
//                punctuation are ignored, grouped per source
//   NAMES        rows still wearing USDA/Open Food Facts cataloguing artefacts a
//                person would never type ("Rice, white, long-grain, raw", "NFS",
//                "UPC: 0123", an empty or one-character name)
//   STAPLES      which everyday Brazilian foods the catalog cannot answer at all
//
// AUDIT_FIX=true deletes duplicates, and deliberately only the ones with
// times_logged 0. `food_logs.food_id` cascades on delete, so removing a food that
// anyone has ever logged would silently delete their diary entries with it - a
// far worse outcome than a duplicate row. Everything else is reported for a human
// to decide on, because the fix is a judgement (merge these two? retranslate that
// name?) rather than a rule.
//
// The name check is report-only for the same reason: retranslating is
// tool/import_usda_foods.dart's job, and re-running it upserts the same rows in
// place (the id is derived from fdcId + locale), so the fix for a bad batch of
// names is that tool, not this one.
//
// SUPABASE_SERVICE_ROLE_KEY bypasses RLS - never put it in .env or commit it.
// Pass it as a one-off shell environment variable only.
//
// Optional env vars:
//   AUDIT_FIX=true        delete never-logged duplicate rows (default: report only)
//   AUDIT_SOURCE=generic  audit one FoodSource only (default: the whole catalog)
//   AUDIT_PAGE_SIZE=1000  rows fetched per query

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:vitta/app/core/text/accent_folding.dart';

const _requestTimeout = Duration(seconds: 45);
const _maxAttempts = 4;
const _defaultPageSize = 1000;

/// Ids per delete request. Small enough to keep the `id=in.(...)` URL well inside
/// any proxy's length limit, large enough that a few thousand rows is a handful of
/// round trips rather than a few thousand.
const _deleteBatchSize = 100;

/// Substrings that only ever appear in a catalogue entry, never in something a
/// person would type into a food diary. "nfs" is USDA's "not further specified".
const _artefactMarkers = ['upc:', 'nfs', 'includes foods for usda', 'gtin', ', raw', ', cooked'];

/// The everyday Brazilian foods a food tracker is asked for most and that
/// USDA/Open Food Facts cover badly or under an English name nobody searches
/// for. This list is a *coverage check*, not data to import: the macros for these
/// have to come from a real source (TACO/UNICAMP, or a USDA equivalent), never
/// from a number written by hand here - the same "return null rather than guess"
/// rule the scan prompts follow, and for the same reason, since a wrong macro
/// poisons a row every user reads.
const _brazilianStaples = [
  'feijao',
  'arroz',
  'farofa',
  'mandioca',
  'tapioca',
  'cuscuz',
  'pao de queijo',
  'pao frances',
  'requeijao',
  'acai',
  'coxinha',
  'brigadeiro',
  'guarana',
  'couve',
  'quiabo',
  'abobora',
  'goiaba',
  'maracuja',
  'caju',
  'castanha de caju',
  'carne seca',
  'linguica',
  'picanha',
  'polvilho',
  'aveia',
];

Future<void> main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final serviceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  if (supabaseUrl == null || serviceRoleKey == null) {
    stderr.writeln('Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables first.');
    exit(1);
  }
  final shouldFix = Platform.environment['AUDIT_FIX'] == 'true';
  final source = Platform.environment['AUDIT_SOURCE']?.trim();
  final pageSize = _envInt('AUDIT_PAGE_SIZE') ?? _defaultPageSize;

  final client = http.Client();
  try {
    final foods = await _fetchAllFoods(
      client,
      supabaseUrl: supabaseUrl,
      serviceRoleKey: serviceRoleKey,
      pageSize: pageSize,
      source: source,
    );
    stdout.writeln('Read ${foods.length} foods${source == null ? '' : ' (source: $source)'}.\n');

    _reportCoverage(foods);
    final duplicates = _duplicateGroups(foods);
    _reportDuplicates(duplicates);
    _reportNames(foods);
    _reportStaples(foods);

    if (!shouldFix) {
      stdout.writeln('\nReport only. Re-run with AUDIT_FIX=true to delete the never-logged duplicates above.');
      return;
    }
    await _deleteDuplicates(client, supabaseUrl: supabaseUrl, serviceRoleKey: serviceRoleKey, duplicates: duplicates);
  } finally {
    client.close();
  }
}

Future<List<_Food>> _fetchAllFoods(
  http.Client client, {
  required String supabaseUrl,
  required String serviceRoleKey,
  required int pageSize,
  String? source,
}) async {
  final foods = <_Food>[];
  final seenIds = <String>{};
  for (var offset = 0; ; offset += pageSize) {
    final uri = Uri.parse(
      '$supabaseUrl/rest/v1/foods'
      '?select=id,name,brand,barcode,source,times_logged,category,grams_per_unit,density_g_per_ml,preparation,'
      'calories_per_100g,protein_per_100g,carbs_per_100g,fat_per_100g,fiber_per_100g,catalog_facts_checked_at,created_at'
      '${source == null ? '' : '&source=eq.$source'}'
      // Ordered by the primary key, never by created_at: the bulk imports write
      // thousands of rows sharing a timestamp, and `order` on a tied column is not
      // a total order - so limit/offset paging returns some rows twice and skips
      // others entirely. That made this tool report one physical row as a
      // duplicate *of itself*, and AUDIT_FIX then deleted its only copy. `id` is
      // unique, so paging over it is stable.
      '&order=id.asc'
      '&limit=$pageSize&offset=$offset',
    );
    final response = await _send(() => client.get(uri, headers: _restHeaders(serviceRoleKey)), description: 'fetch foods');
    if (response.statusCode >= 300) {
      stderr.writeln('Failed to read foods (${response.statusCode}): ${response.body}');
      stderr.writeln('Re-run supabase/schema.sql if density_g_per_ml or preparation is missing.');
      exit(1);
    }
    final page = (jsonDecode(response.body) as List<dynamic>).cast<Map<String, dynamic>>();
    // Belt and braces on top of the stable order above: a row read twice must
    // never become its own duplicate group, because the fix deletes those.
    for (final food in page.map(_Food.fromRow)) {
      if (seenIds.add(food.id)) {
        foods.add(food);
      }
    }
    if (page.length < pageSize) {
      return foods;
    }
  }
}

void _reportCoverage(List<_Food> foods) {
  stdout.writeln('COVERAGE');
  final bySource = <String, List<_Food>>{};
  for (final food in foods) {
    bySource.putIfAbsent(food.source, () => []).add(food);
  }
  for (final MapEntry(key: source, value: rows) in bySource.entries) {
    stdout.writeln(
      '  $source: ${rows.length} rows'
      ' | asked ${_percent(rows.where((food) => food.isFactChecked).length, rows.length)}'
      ' | category ${_percent(rows.where((food) => food.category != null).length, rows.length)}'
      ' | unit weight ${_percent(rows.where((food) => food.gramsPerUnit != null).length, rows.length)}'
      ' | density ${_percent(rows.where((food) => food.densityGPerMl != null).length, rows.length)}'
      ' | raw/cooked ${_percent(rows.where((food) => food.preparation != null).length, rows.length)}',
    );
  }
  final pending = foods.where((food) => !food.isFactChecked).length;
  if (pending > 0) {
    stdout.writeln('  $pending rows have never been asked - run tool/populate_food_facts.dart.');
  }
}

/// A duplicate is a row that is the same food *and says the same thing about it*:
/// same source, same name, same brand and the same macros. The macros are part of
/// the key on purpose - the catalog holds 20 rows named "Coca cola", and they are
/// separate barcodes from separate countries whose numbers do not all agree.
/// Merging on the name alone would pick one country's figures and delete the
/// rest, which is a data change disguised as a cleanup; requiring the numbers to
/// match keeps it to rows that are genuinely interchangeable.
///
/// The source is in the key too, so a curated "Arroz" and a branded "Arroz" are
/// never called duplicates of each other: they are different rows on purpose, one
/// whole-food and one product.
List<List<_Food>> _duplicateGroups(List<_Food> foods) {
  final byKey = <String, List<_Food>>{};
  for (final food in foods) {
    if (food.normalizedName.isEmpty) {
      continue;
    }
    byKey.putIfAbsent(food.duplicateKey, () => []).add(food);
  }
  return byKey.values.where((group) => group.length > 1).toList();
}

void _reportDuplicates(List<List<_Food>> duplicates) {
  stdout.writeln('\nDUPLICATES');
  if (duplicates.isEmpty) {
    stdout.writeln('  none');
    return;
  }
  var deletable = 0;
  for (final group in duplicates) {
    final survivor = _survivorOf(group);
    final removable = group.where((food) => food != survivor && food.timesLogged == 0).toList();
    deletable += removable.length;
    stdout.writeln('  "${survivor.name}" x${group.length} (${group.map((food) => 'logged ${food.timesLogged}').join(', ')})');
    for (final food in group.where((food) => food != survivor && food.timesLogged > 0)) {
      stdout.writeln('    keeping ${food.id} - logged ${food.timesLogged} times, deleting it would delete those diary entries');
    }
  }
  stdout.writeln('  ${duplicates.length} groups, $deletable rows safe to delete (never logged).');
}

/// The row everything else in its group defers to: the most-logged one, then the
/// one carrying a barcode (it is the row a future scan of that product will find,
/// via foods_barcode_unique_idx), then the oldest - so re-running the audit always
/// picks the same survivor.
_Food _survivorOf(List<_Food> group) => group.reduce((survivor, food) => _beats(food, survivor) ? food : survivor);

bool _beats(_Food food, _Food survivor) => switch (food.timesLogged.compareTo(survivor.timesLogged)) {
  > 0 => true,
  < 0 => false,
  _ => switch ((food.hasBarcode, survivor.hasBarcode)) {
    (true, false) => true,
    (false, true) => false,
    _ => food.createdAt.isBefore(survivor.createdAt),
  },
};

void _reportNames(List<_Food> foods) {
  stdout.writeln('\nNAMES');
  final suspicious = foods.where((food) => food.nameArtefact != null).toList();
  if (suspicious.isEmpty) {
    stdout.writeln('  none');
    return;
  }
  for (final food in suspicious.take(40)) {
    stdout.writeln('  [${food.nameArtefact}] ${food.name} (${food.source})');
  }
  if (suspicious.length > 40) {
    stdout.writeln('  ... and ${suspicious.length - 40} more');
  }
  final generic = suspicious.where((food) => food.source == 'generic').length;
  stdout.writeln('  ${suspicious.length} names read like a catalogue entry ($generic of them generic).');
  stdout.writeln('  The generic ones are fixed by re-running tool/import_usda_foods.dart, which upserts them in place.');
  stdout.writeln('  The rest came from Open Food Facts as-is, so they are only worth touching if a user actually searches them.');
}

void _reportStaples(List<_Food> foods) {
  stdout.writeln('\nSTAPLES');
  final names = foods.map((food) => food.normalizedName).toList();
  final missing = _brazilianStaples.where((staple) => !names.any((name) => name.contains(staple))).toList();
  if (missing.isEmpty) {
    stdout.writeln('  every staple is covered');
    return;
  }
  stdout.writeln('  ${missing.length}/${_brazilianStaples.length} not in the catalog: ${missing.join(', ')}');
  stdout.writeln('  These need macros from a real source (TACO/UNICAMP or USDA), not numbers written by hand.');
}

Future<void> _deleteDuplicates(
  http.Client client, {
  required String supabaseUrl,
  required String serviceRoleKey,
  required List<List<_Food>> duplicates,
}) async {
  final ids = [
    for (final group in duplicates)
      for (final food in group)
        if (food != _survivorOf(group) && food.timesLogged == 0) food.id,
  ];
  if (ids.isEmpty) {
    stdout.writeln('\nNothing safe to delete.');
    return;
  }
  stdout.writeln('\nDeleting ${ids.length} never-logged duplicate rows...');
  // Batched through `id=in.(...)` rather than one request per row: a few thousand
  // sequential round trips is minutes of waiting for a delete Postgres does in one.
  var deleted = 0;
  for (final batch in _batches(ids, _deleteBatchSize)) {
    final response = await _send(
      () => client.delete(
        Uri.parse('$supabaseUrl/rest/v1/foods?id=in.(${batch.join(',')})'),
        headers: {..._restHeaders(serviceRoleKey), 'Prefer': 'return=minimal'},
      ),
      description: 'delete ${batch.length} rows',
    );
    if (response.statusCode >= 300) {
      // Same reasoning as the importers: a rejected write means every write after
      // it fails identically, so stopping beats printing a reassuring summary.
      stderr.writeln('Failed to delete a batch (${response.statusCode}): ${response.body}');
      stderr.writeln('$deleted rows were deleted before this. Re-running the audit is safe and resumes.');
      exit(1);
    }
    deleted += batch.length;
    stdout.writeln('  deleted $deleted/${ids.length}');
  }
  stdout.writeln('Done. Deleted $deleted rows.');
}

Iterable<List<T>> _batches<T>(List<T> items, int size) sync* {
  for (var start = 0; start < items.length; start += size) {
    yield items.sublist(start, (start + size).clamp(0, items.length));
  }
}

String _percent(int part, int total) => total == 0 ? '-' : '$part (${(part * 100 / total).round()}%)';

Future<http.Response> _send(Future<http.Response> Function() request, {required String description}) async {
  for (var attempt = 1; ; attempt++) {
    try {
      final response = await request().timeout(_requestTimeout);
      if (response.statusCode != 429 && response.statusCode < 500) {
        return response;
      }
      if (attempt >= _maxAttempts) {
        return response;
      }
      final delay = Duration(seconds: 2 << attempt);
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

class _Food {
  _Food({
    required this.id,
    required this.name,
    required this.brand,
    required this.barcode,
    required this.source,
    required this.timesLogged,
    required this.category,
    required this.gramsPerUnit,
    required this.densityGPerMl,
    required this.preparation,
    required this.macros,
    required this.isFactChecked,
    required this.createdAt,
  });

  factory _Food.fromRow(Map<String, dynamic> row) => _Food(
    id: row['id'] as String,
    name: (row['name'] as String?) ?? '',
    brand: row['brand'] as String?,
    barcode: row['barcode'] as String?,
    source: (row['source'] as String?) ?? 'unknown',
    timesLogged: (row['times_logged'] as num?)?.toInt() ?? 0,
    category: row['category'] as String?,
    gramsPerUnit: (row['grams_per_unit'] as num?)?.toDouble(),
    densityGPerMl: (row['density_g_per_ml'] as num?)?.toDouble(),
    preparation: row['preparation'] as String?,
    macros: _macrosOf(row),
    isFactChecked: row['catalog_facts_checked_at'] != null,
    createdAt: DateTime.parse(row['created_at'] as String),
  );

  static String _macrosOf(Map<String, dynamic> row) => [
    'calories_per_100g',
    'protein_per_100g',
    'carbs_per_100g',
    'fat_per_100g',
    'fiber_per_100g',
  ].map((column) => ((row[column] as num?)?.toDouble() ?? 0).toStringAsFixed(1)).join('/');

  final String id;
  final String name;
  final String? brand;
  final String? barcode;
  final String source;
  final int timesLogged;
  final String? category;
  final double? gramsPerUnit;
  final double? densityGPerMl;
  final String? preparation;
  final String macros;
  final bool isFactChecked;
  final DateTime createdAt;

  bool get hasBarcode => (barcode ?? '').trim().isNotEmpty;

  String get duplicateKey => '$source|$normalizedName|$normalizedBrand|$macros';

  /// Folded the same way catalog search folds a query (AccentFolding is the app's
  /// own), then stripped of punctuation and collapsed whitespace, so "Pão de
  /// Queijo" and "pao de queijo," land on one key.
  String get normalizedName => _normalize(name);

  String get normalizedBrand => _normalize(brand ?? '');

  String? get nameArtefact {
    if (name.trim().length < 2) {
      return 'too short';
    }
    final folded = _normalize(name);
    return _artefactMarkers.where(folded.contains).firstOrNull ?? (name.split(',').length > 3 ? 'comma-heavy' : null);
  }

  static String _normalize(String value) =>
      AccentFolding.fold(value).replaceAll(RegExp('[^a-z0-9, ]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}
