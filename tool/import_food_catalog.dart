// One-time/occasional bulk import of Open Food Facts products into the
// shared `foods` catalog (see supabase/schema.sql), so search can eventually
// stop hitting the Open Food Facts API at runtime. Safe to re-run: the upsert
// keys on `barcode` (merge-duplicates), so a second run backfills columns
// added since the first import (e.g. `micronutrients`) into existing rows
// without duplicating them or disturbing user-owned fields.
//
// Run with:
//   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... dart run tool/import_food_catalog.dart
//
// SUPABASE_SERVICE_ROLE_KEY bypasses RLS - never put it in .env (flutter_dotenv
// loads that file into the shipped app) or commit it anywhere. Pass it as a
// one-off shell environment variable only.
//
// Requires supabase/schema.sql to have been re-run first (foods.user_id must
// be nullable - imported rows have no specific user).

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:vitta/app/domain/diet/entities/nutrient.dart';

const _countries = ['Brazil', 'United States'];
const _pageSize = 100;
const _maxPagesPerCountry = 50;
const _userAgent = 'Vitta - Flutter - Version 1.0 - https://github.com/rodrigobastosv/vitta';
const _requestDelay = Duration(seconds: 2);
const _maxFetchAttempts = 4;
const _retryDelay = Duration(seconds: 4);
const _countryCooldown = Duration(seconds: 10);

Future<void> main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final serviceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  if (supabaseUrl == null || serviceRoleKey == null) {
    stderr.writeln('Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables first.');
    exit(1);
  }

  final client = http.Client();
  var imported = 0;
  var skipped = 0;

  try {
    for (final country in _countries) {
      if (country != _countries.first) {
        stdout.writeln('Cooling down ${_countryCooldown.inSeconds}s before the next country...');
        await Future.delayed(_countryCooldown);
      }
      stdout.writeln('Importing products for $country...');
      for (var page = 1; page <= _maxPagesPerCountry; page++) {
        final products = await _fetchPage(client, country: country, page: page);
        if (products == null) {
          stdout.writeln('  page $page: giving up after $_maxFetchAttempts attempts, skipping to next page');
          continue;
        }
        if (products.isEmpty) {
          break;
        }

        final rows = products.map(_toFoodRow).nonNulls.toList();
        skipped += products.length - rows.length;
        if (rows.isNotEmpty) {
          await _upsertRows(client, supabaseUrl: supabaseUrl, serviceRoleKey: serviceRoleKey, rows: rows);
          imported += rows.length;
        }
        stdout.writeln('  page $page: +${rows.length} (total imported: $imported, skipped: $skipped)');
        await Future.delayed(_requestDelay);
      }
    }
  } finally {
    client.close();
  }

  stdout.writeln('Done. Imported $imported products, skipped $skipped (missing name/barcode/macros).');
}

// Returns null if every attempt failed (transient error, give up on this
// page but keep going); an empty list means the country genuinely has no
// more products (stop paginating for it).
Future<List<Map<String, dynamic>>?> _fetchPage(http.Client client, {required String country, required int page}) async {
  // /api/v2/search returns 503s as of this writing; /cgi/search.pl is the
  // same legacy endpoint OpenFoodFactsDataSource already uses for in-app
  // search, and it's what's actually reliable, though still prone to
  // occasional transient 503s under load - hence the retry loop below.
  // sort_by=unique_scans_n biases the import towards well-known/well-scanned
  // products first, which tend to have more complete nutriment data.
  final uri = Uri.https('world.openfoodfacts.org', '/cgi/search.pl', {
    'action': 'process',
    'json': '1',
    'page_size': '$_pageSize',
    'page': '$page',
    'tagtype_0': 'countries',
    'tag_contains_0': 'contains',
    'tag_0': country,
    'sort_by': 'unique_scans_n',
    'fields': 'code,product_name,brands,nutriments,image_url',
  });

  for (var attempt = 1; attempt <= _maxFetchAttempts; attempt++) {
    final response = await client.get(uri, headers: {'User-Agent': _userAgent});
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return (body['products'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    }
    stderr.writeln('  request failed (${response.statusCode}), attempt $attempt/$_maxFetchAttempts');
    if (attempt < _maxFetchAttempts) {
      await Future.delayed(_retryDelay);
    }
  }
  return null;
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
    'micronutrients': {
      for (final nutrient in Nutrient.values) nutrient.wireKey: ?_numOrNull(nutriments[nutrient.offKey]),
    },
    'image_url': product['image_url'] as String?,
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
