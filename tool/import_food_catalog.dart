// One-time/occasional bulk import of Open Food Facts products into the shared
// `foods` catalog (see supabase/schema.sql), so search can eventually stop
// hitting the Open Food Facts API at runtime. Safe to re-run: the upsert keys
// on `barcode` (merge-duplicates), so a second run backfills columns added
// since the first import (e.g. `micronutrients`) into existing rows without
// duplicating them or disturbing user-owned fields.
//
// This reads Open Food Facts' bulk JSONL data export rather than scraping the
// search API - the export has no rate limit, which the search endpoint does.
// It streams the gzipped file line by line (one product JSON per line) so it
// never holds the whole multi-GB dataset in memory, filtering to a curated
// subset (target countries + a popularity floor) so the catalog stays a
// relevant slice, not a mirror of the whole export.
//
// The export is several GB. Download it once (resumable) and point the tool at
// the local file - far more robust than streaming it over HTTP in one shot:
//   wget -c https://static.openfoodfacts.org/data/openfoodfacts-products.jsonl.gz
//   OFF_EXPORT_PATH=openfoodfacts-products.jsonl.gz \
//   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... dart run tool/import_food_catalog.dart
//
// Without OFF_EXPORT_PATH it streams straight from OFF_EXPORT_URL (default the
// public export), which works but can't resume if the connection drops.
//
// SUPABASE_SERVICE_ROLE_KEY bypasses RLS - never put it in .env (flutter_dotenv
// loads that file into the shipped app) or commit it anywhere. Pass it as a
// one-off shell environment variable only.
//
// Requires supabase/schema.sql to have been re-run first (foods.user_id must
// be nullable - imported rows have no specific user).
//
// Optional env vars:
//   OFF_EXPORT_PATH=...                      local .jsonl(.gz) export to read
//   OFF_EXPORT_URL=...                       remote export (default OFF public)
//   IMPORT_COUNTRIES=Brazil,United States    keep products sold here (empty = all)
//   IMPORT_MIN_SCANS=5                        keep products scanned at least N times
//   IMPORT_MAX_PRODUCTS=...                   stop after ~N imported (default: all)
//   IMPORT_BATCH_SIZE=500                     rows per upsert request

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:vitta/app/domain/diet/entities/nutrient.dart';

const _exportUrl = 'https://static.openfoodfacts.org/data/openfoodfacts-products.jsonl.gz';
const _userAgent = 'Vitta - Flutter - Version 1.0 - https://github.com/rodrigobastosv/vitta';
const _defaultCountries = ['Brazil', 'United States'];
const _defaultMinScans = 5;
const _defaultBatchSize = 500;
const _progressEvery = 100000;

Future<void> main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final serviceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  if (supabaseUrl == null || serviceRoleKey == null) {
    stderr.writeln('Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables first.');
    exit(1);
  }

  final countryTags = _countriesFromEnv().map(_toCountryTag).toSet();
  final minScans = _envInt('IMPORT_MIN_SCANS') ?? _defaultMinScans;
  final maxProducts = _envInt('IMPORT_MAX_PRODUCTS');
  final batchSize = _envInt('IMPORT_BATCH_SIZE') ?? _defaultBatchSize;
  final exportPath = Platform.environment['OFF_EXPORT_PATH'];
  final exportUrl = Platform.environment['OFF_EXPORT_URL'] ?? _exportUrl;
  stdout.writeln(
    'Filter: countries ${countryTags.isEmpty ? '(all)' : countryTags.join(', ')}, min scans $minScans'
    '${maxProducts == null ? '' : ', cap ~$maxProducts'}.',
  );

  final client = http.Client();
  var scanned = 0;
  var imported = 0;
  var skipped = 0;
  final batch = <Map<String, dynamic>>[];

  Future<void> flush() async {
    if (batch.isEmpty) {
      return;
    }
    await _upsertRows(client, supabaseUrl: supabaseUrl, serviceRoleKey: serviceRoleKey, rows: batch);
    imported += batch.length;
    batch.clear();
    stdout.writeln('  imported $imported (scanned $scanned, skipped $skipped)');
  }

  try {
    final lines = await _openExportLines(client, exportPath: exportPath, exportUrl: exportUrl);
    await for (final line in lines) {
      if (line.trim().isEmpty) {
        continue;
      }
      scanned++;
      if (scanned % _progressEvery == 0) {
        stdout.writeln('  scanned $scanned lines...');
      }

      final product = _decodeLine(line);
      if (product == null || !_matchesCountry(product, countryTags) || !_isPopularEnough(product, minScans)) {
        skipped++;
        continue;
      }
      final row = _toFoodRow(product);
      if (row == null) {
        skipped++;
        continue;
      }

      batch.add(row);
      if (batch.length >= batchSize) {
        await flush();
        if (maxProducts != null && imported >= maxProducts) {
          break;
        }
      }
    }
    await flush();
  } finally {
    client.close();
  }

  stdout.writeln('Done. Scanned $scanned, imported $imported, skipped $skipped (wrong country, too few scans, or missing macros).');
}

Future<Stream<String>> _openExportLines(http.Client client, {required String? exportPath, required String exportUrl}) async {
  Stream<List<int>> bytes;
  var gzipped = true;
  if (exportPath != null) {
    stdout.writeln('Reading export from $exportPath');
    bytes = File(exportPath).openRead();
    gzipped = exportPath.endsWith('.gz');
  } else {
    stdout.writeln('Streaming export from $exportUrl (several GB; set OFF_EXPORT_PATH to a local download for a resumable run)');
    final request = http.Request('GET', Uri.parse(exportUrl))..headers['User-Agent'] = _userAgent;
    final response = await client.send(request);
    if (response.statusCode != 200) {
      stderr.writeln('Failed to download export (${response.statusCode}).');
      exit(1);
    }
    bytes = response.stream;
  }
  final decompressed = gzipped ? bytes.transform(gzip.decoder) : bytes;
  return decompressed.transform(utf8.decoder).transform(const LineSplitter());
}

Map<String, dynamic>? _decodeLine(String line) {
  try {
    return jsonDecode(line) as Map<String, dynamic>;
  } on FormatException {
    return null;
  }
}

String _toCountryTag(String country) => 'en:${country.trim().toLowerCase().replaceAll(' ', '-')}';

bool _matchesCountry(Map<String, dynamic> product, Set<String> countryTags) {
  if (countryTags.isEmpty) {
    return true;
  }
  final tags = product['countries_tags'];
  return tags is List && tags.any(countryTags.contains);
}

bool _isPopularEnough(Map<String, dynamic> product, int minScans) {
  if (minScans <= 0) {
    return true;
  }
  return (_numOrNull(product['unique_scans_n']) ?? 0) >= minScans;
}

// Unset IMPORT_COUNTRIES falls back to the curated default; an explicitly empty
// value (IMPORT_COUNTRIES=) means "all countries" - matching the documented
// "(empty = all)" behaviour, which the presence check here is what distinguishes
// from the unset case.
List<String> _countriesFromEnv() {
  final raw = Platform.environment['IMPORT_COUNTRIES'];
  if (raw == null) {
    return _defaultCountries;
  }
  return raw.split(',').map((value) => value.trim()).where((value) => value.isNotEmpty).toList();
}

int? _envInt(String key) {
  final raw = Platform.environment[key];
  return raw == null ? null : int.tryParse(raw.trim());
}

Map<String, dynamic>? _toFoodRow(Map<String, dynamic> product) {
  final name = product['product_name'] as String?;
  final barcode = product['code'] as String?;
  final nutriments = product['nutriments'] as Map<String, dynamic>?;
  if (name == null || name.isEmpty || barcode == null || barcode.isEmpty || nutriments == null) {
    return null;
  }

  final calories = _numOrNull(nutriments['energy-kcal_100g']);
  final protein = _numOrNull(nutriments['proteins_100g']);
  final carbs = _numOrNull(nutriments['carbohydrates_100g']);
  final fat = _numOrNull(nutriments['fat_100g']);
  if (calories == null || protein == null || carbs == null || fat == null) {
    return null;
  }

  // user_id is intentionally omitted, not set to null: on INSERT the column
  // falls back to its null default (imported rows are unowned, as the schema
  // intends), and on the barcode DO UPDATE (see _upsertRows' merge-duplicates)
  // an absent column is left untouched. So re-running the import to backfill a
  // newly added column like `micronutrients` refreshes the Open Food Facts
  // fields without resetting the owner of a row a user first logged themselves.
  return {
    'name': name,
    'brand': product['brands'] as String?,
    'barcode': barcode,
    'source': 'open_food_facts',
    'calories_per_100g': calories,
    'protein_per_100g': protein,
    'carbs_per_100g': carbs,
    'fat_per_100g': fat,
    'fiber_per_100g': _numOrNull(nutriments['fiber_100g']) ?? 0,
    'micronutrients': {for (final nutrient in Nutrient.values) nutrient.wireKey: ?_numOrNull(nutriments[nutrient.offKey])},
    'image_url': (product['image_url'] ?? product['image_front_url'] ?? product['image_front_small_url']) as String?,
  };
}

double? _numOrNull(dynamic value) => switch (value) {
  final num n => n.toDouble(),
  _ => null,
};

Future<void> _upsertRows(
  http.Client client, {
  required String supabaseUrl,
  required String serviceRoleKey,
  required List<Map<String, dynamic>> rows,
}) async {
  final uri = Uri.parse('$supabaseUrl/rest/v1/foods?on_conflict=barcode');
  final response = await client.post(
    uri,
    headers: {
      'apikey': serviceRoleKey,
      'Authorization': 'Bearer $serviceRoleKey',
      'Content-Type': 'application/json',
      'Prefer': 'resolution=merge-duplicates,return=minimal',
    },
    body: jsonEncode(rows),
  );
  if (response.statusCode >= 300) {
    stderr.writeln('  upsert failed (${response.statusCode}): ${response.body}');
  }
}
