// Seeds the curated `generic` tier with Brazilian foods from TACO (Tabela
// Brasileira de Composição de Alimentos, NEPA/UNICAMP) - issue #285.
//
// Why this exists alongside import_usda_foods.dart: USDA is an excellent table
// of foods eaten in the United States, and Open Food Facts is a barcode database
// of packaged products. Neither can answer "farofa", "tapioca", "cuscuz", "pão
// de queijo", "requeijão" or "açaí", and an audit of the live catalog found the
// curated tier held ZERO rows for every one of them. Those are not exotic - they
// are what the app's users actually eat, and a diet tracker that cannot find
// them is the complaint issue #285 opens with.
//
// Two things make TACO rows better than a translated USDA row for these foods:
// the names are already Brazilian Portuguese (no translation step, so no
// silently-omitted-name bug to work around), and the figures are laboratory
// measurements of food as sold and prepared in Brazil.
//
// THE DATA IS NOT BUNDLED, AND THAT IS DELIBERATE. TACO is published by
// NEPA/UNICAMP as a PDF and an Excel workbook; its terms for redistribution
// inside a third-party product are not clearly stated (the related TBCA states
// free access "with proper author credits"). So this tool reads an export YOU
// supply, exactly as import_usda_foods.dart reads USDA downloads, rather than
// carrying a copy in the repo - and checking those terms for your use is a
// prerequisite, not a formality. Writing the numbers into this file by hand is
// the one thing not to do: a macro invented here poisons a row every user reads,
// the same rule the scan prompts follow by returning null rather than guessing.
//
// Export the TACO workbook to CSV with a header row, then:
//   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... \
//   TACO_CSV_PATH=taco.csv \
//   dart run tool/import_taco_foods.dart
//
// SUPABASE_SERVICE_ROLE_KEY bypasses RLS - never put it in .env (flutter_dotenv
// loads that file into the shipped app) or commit it. Pass it as a one-off shell
// environment variable only. Requires supabase/schema.sql to have been re-run
// first (the source check must allow 'generic').
//
// Expected columns (matched case- and accent-insensitively, so the workbook's
// own Portuguese headers work as exported):
//   numero | descricao | energia | proteina | carboidrato | lipideos | fibra
//   and optionally: categoria
//
// Optional env vars:
//   TACO_DRY_RUN=true      parse and report without writing anything
//   IMPORT_MAX_FOODS=...   stop after ~N imported (default: all)
//   IMPORT_BATCH_SIZE=40   foods per upsert

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:vitta/app/core/text/accent_folding.dart';
import 'package:vitta/app/domain/diet/entities/food_category.dart';
import 'package:vitta/app/domain/diet/entities/food_plausibility.dart';
import 'package:vitta/app/domain/diet/entities/food_preparation.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';

const _requestTimeout = Duration(seconds: 45);
const _maxAttempts = 4;
const _defaultBatchSize = 40;

// TACO marks an unmeasured nutrient with '*' or 'NA' and a trace amount with
// 'Tr'. A trace is genuinely ~0 and is read as such; an unmeasured value is NOT
// - it is missing data, and reading it as 0 would state a measurement that was
// never taken. A row missing any macro is skipped rather than guessed at.
const _traceMarkers = ['tr', 'traco', 'tracos'];
const _missingMarkers = ['*', 'na', 'n/a', '', '-'];

const _cookedMarkers = ['cozido', 'cozida', 'assado', 'assada', 'frito', 'frita', 'grelhado', 'grelhada', 'refogado', 'refogada', 'ensopado', 'ensopada'];
const _rawMarkers = ['cru', 'crua', 'cru,', 'in natura'];

// TACO's own food groups, folded, onto the app's FoodCategory. A group with no
// sensible mapping is left null rather than forced into `condiment`: a wrong
// category shows the wrong icon on every row in it.
const _categoryByGroup = {
  'cereais e derivados': FoodCategory.grain,
  'verduras hortalicas e derivados': FoodCategory.vegetable,
  'frutas e derivados': FoodCategory.fruit,
  'gorduras e oleos': FoodCategory.fatOil,
  'pescados e frutos do mar': FoodCategory.protein,
  'carnes e derivados': FoodCategory.protein,
  'aves e derivados': FoodCategory.protein,
  'leite e derivados': FoodCategory.dairyEgg,
  'ovos e derivados': FoodCategory.dairyEgg,
  'bebidas': FoodCategory.beverage,
  'produtos acucarados': FoodCategory.sweet,
  'leguminosas e derivados': FoodCategory.legumeNut,
  'nozes e sementes': FoodCategory.legumeNut,
};

Future<void> main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final serviceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  final csvPath = Platform.environment['TACO_CSV_PATH'];
  final isDryRun = Platform.environment['TACO_DRY_RUN'] == 'true';

  if (csvPath == null) {
    stderr.writeln('Set TACO_CSV_PATH to a CSV export of the TACO table.');
    exit(1);
  }
  if (!isDryRun && (supabaseUrl == null || serviceRoleKey == null)) {
    stderr.writeln('Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY, or TACO_DRY_RUN=true to parse without writing.');
    exit(1);
  }

  final file = File(csvPath);
  if (!file.existsSync()) {
    stderr.writeln('No such file: $csvPath');
    exit(1);
  }

  final parsed = _readFoods(file);
  final maxFoods = _envInt('IMPORT_MAX_FOODS');
  final foods = maxFoods == null ? parsed.foods : parsed.foods.take(maxFoods).toList();
  stdout.writeln('Read ${parsed.foods.length} usable foods from $csvPath.');
  if (parsed.skipped > 0) {
    stdout.writeln('Skipped ${parsed.skipped} row(s) with missing or implausible figures.');
  }
  if (foods.isEmpty) {
    stderr.writeln('Nothing to import. Check that the header row names the expected columns.');
    exit(1);
  }

  if (isDryRun) {
    for (final food in foods.take(20)) {
      stdout.writeln('  ${food.name} | ${food.calories} kcal | P${food.protein} C${food.carbs} F${food.fat} | ${food.category?.wireValue ?? '-'} | ${food.preparation?.wireValue ?? '-'}');
    }
    stdout.writeln('\nDry run. Nothing was written.');
    return;
  }

  final batchSize = _envInt('IMPORT_BATCH_SIZE') ?? _defaultBatchSize;
  final client = http.Client();
  var imported = 0;
  try {
    for (var start = 0; start < foods.length; start += batchSize) {
      final batch = foods.sublist(start, (start + batchSize).clamp(0, foods.length));
      await _upsertRows(
        client,
        supabaseUrl: supabaseUrl!,
        serviceRoleKey: serviceRoleKey!,
        rows: [for (final food in batch) food.toRow()],
      );
      imported += batch.length;
      stdout.writeln('  imported $imported/${foods.length}');
    }
  } finally {
    client.close();
  }
  stdout.writeln('Done. Imported $imported Brazilian foods.');
}

({List<_TacoFood> foods, int skipped}) _readFoods(File file) {
  final rows = _parseCsv(file.readAsStringSync());
  if (rows.isEmpty) {
    return (foods: const <_TacoFood>[], skipped: 0);
  }
  final header = [for (final cell in rows.first) _fold(cell)];
  int columnFor(List<String> candidates) {
    for (final candidate in candidates) {
      final index = header.indexWhere((cell) => cell.contains(candidate));
      if (index >= 0) {
        return index;
      }
    }
    return -1;
  }

  final numberColumn = columnFor(['numero', 'codigo', 'id']);
  final nameColumn = columnFor(['descricao', 'alimento', 'nome']);
  final energyColumn = columnFor(['energia', 'kcal']);
  final proteinColumn = columnFor(['proteina']);
  final carbsColumn = columnFor(['carboidrato']);
  final fatColumn = columnFor(['lipideo', 'gordura']);
  final fiberColumn = columnFor(['fibra']);
  final groupColumn = columnFor(['categoria', 'grupo']);

  if ([nameColumn, energyColumn, proteinColumn, carbsColumn, fatColumn].any((index) => index < 0)) {
    stderr.writeln('The CSV header must name a description column and energia/proteina/carboidrato/lipideos columns.');
    stderr.writeln('Found header: ${rows.first.join(' | ')}');
    exit(1);
  }

  final foods = <_TacoFood>[];
  var skipped = 0;
  for (var index = 1; index < rows.length; index++) {
    final row = rows[index];
    String cell(int column) => column >= 0 && column < row.length ? row[column].trim() : '';

    final name = cell(nameColumn);
    final calories = _number(cell(energyColumn));
    final protein = _number(cell(proteinColumn));
    final carbs = _number(cell(carbsColumn));
    final fat = _number(cell(fatColumn));
    if (name.isEmpty || calories == null || protein == null || carbs == null || fat == null) {
      skipped++;
      continue;
    }
    if (!FoodPlausibility.isPlausible(caloriesPer100g: calories, proteinPer100g: protein, carbsPer100g: carbs, fatPer100g: fat)) {
      skipped++;
      continue;
    }
    foods.add(
      _TacoFood(
        // The row's own TACO number where the export carries one, else its
        // position in the file - so a re-run of the same export upserts in place
        // rather than duplicating the whole table.
        number: int.tryParse(cell(numberColumn)) ?? index,
        name: _titleCase(name),
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        fiber: _number(cell(fiberColumn)) ?? 0,
        category: _categoryByGroup[_fold(cell(groupColumn))],
        preparation: _preparationOf(name),
      ),
    );
  }
  return (foods: foods, skipped: skipped);
}

// TACO states a raw and a cooked entry as separate foods, exactly as USDA does,
// so the preparation is read off the name rather than converted - 100 g of raw
// rice is roughly three times the calories of 100 g of cooked rice, and only a
// stated preparation is recorded (see issue #253).
FoodPreparation? _preparationOf(String name) {
  final folded = _fold(name);
  if (_cookedMarkers.any(folded.contains)) {
    return FoodPreparation.cooked;
  }
  return _rawMarkers.any(folded.contains) ? FoodPreparation.raw : null;
}

// TACO writes decimals with a comma, and marks a trace as "Tr" and an unmeasured
// nutrient with "*" or "NA". Null means "not measured", which the caller skips
// the whole row over rather than reading as zero.
double? _number(String raw) {
  final value = raw.trim();
  final folded = _fold(value);
  if (_traceMarkers.contains(folded)) {
    return 0;
  }
  if (_missingMarkers.contains(folded)) {
    return null;
  }
  // The dot is only a thousands separator when a comma is present to be the
  // decimal one. Stripping it unconditionally reads a dot-decimal export - what
  // Excel writes under an English locale - as ten times the real figure, which
  // is a silently wrong macro on every row rather than a visible failure.
  final normalized = value.contains(',') ? value.replaceAll('.', '').replaceAll(',', '.') : value;
  return double.tryParse(normalized);
}

// TACO names are upper case in the workbook ("ARROZ, INTEGRAL, COZIDO"), which
// shouts in a list. Only the first letter is raised: lowering the rest would
// also lower a proper noun, and TACO carries few of those.
String _titleCase(String name) {
  final cleaned = name.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (cleaned.isEmpty) {
    return cleaned;
  }
  final isAllCaps = cleaned == cleaned.toUpperCase();
  final body = isAllCaps ? cleaned.toLowerCase() : cleaned;
  return body[0].toUpperCase() + body.substring(1);
}

String _fold(String value) => AccentFolding.fold(value).replaceAll(RegExp('[^a-z0-9 ]'), '').trim();

// A minimal RFC 4180 reader: quoted fields, doubled quotes inside them, and
// commas or semicolons as the delimiter (a Brazilian Excel exports semicolons,
// because the comma is the decimal separator).
List<List<String>> _parseCsv(String content) {
  final delimiter = _delimiterOf(content);
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;
  for (var index = 0; index < content.length; index++) {
    final character = content[index];
    if (inQuotes) {
      if (character == '"') {
        if (index + 1 < content.length && content[index + 1] == '"') {
          field.write('"');
          index++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(character);
      }
      continue;
    }
    switch (character) {
      case '"':
        inQuotes = true;
      case _ when character == delimiter:
        row.add(field.toString());
        field.clear();
      case '\n':
        row.add(field.toString());
        field.clear();
        rows.add(row);
        row = <String>[];
      case '\r':
        break;
      default:
        field.write(character);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    rows.add(row);
  }
  return [for (final parsedRow in rows) if (parsedRow.any((cell) => cell.trim().isNotEmpty)) parsedRow];
}

String _delimiterOf(String content) {
  final firstLine = content.split('\n').first;
  return firstLine.split(';').length > firstLine.split(',').length ? ';' : ',';
}

Future<void> _upsertRows(
  http.Client client, {
  required String supabaseUrl,
  required String serviceRoleKey,
  required List<Map<String, dynamic>> rows,
}) async {
  final response = await _send(
    () => client.post(
      Uri.parse('$supabaseUrl/rest/v1/foods?on_conflict=id'),
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': 'Bearer $serviceRoleKey',
        'Content-Type': 'application/json',
        'Prefer': 'resolution=merge-duplicates,return=minimal',
      },
      body: jsonEncode(rows),
    ),
    description: 'upsert ${rows.length} rows',
  );
  if (response.statusCode >= 300) {
    // Same reasoning as the other importers: a rejected write means every write
    // after it fails identically, so stopping beats reporting a cheerful total
    // over an empty table.
    stderr.writeln('Failed to upsert a batch (${response.statusCode}): ${response.body}');
    exit(1);
  }
}

Future<http.Response> _send(Future<http.Response> Function() request, {required String description}) async {
  for (var attempt = 1; ; attempt++) {
    try {
      // package:http waits forever without one, and a stalled connection hung a
      // real import run with no output - see import_exercise_catalog.dart.
      return await request().timeout(_requestTimeout);
    } on Exception catch (error) {
      if (attempt >= _maxAttempts) {
        stderr.writeln('Giving up on $description after $attempt attempts: $error');
        exit(1);
      }
      await Future<void>.delayed(Duration(seconds: attempt * 2));
    }
  }
}

int? _envInt(String key) {
  final raw = Platform.environment[key];
  return raw == null ? null : int.tryParse(raw.trim());
}

class _TacoFood {
  _TacoFood({
    required this.number,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.category,
    required this.preparation,
  });

  final int number;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final FoodCategory? category;
  final FoodPreparation? preparation;

  // A deterministic UUID (valid version-4 layout) keyed on the TACO number, with
  // its own leading segment so a TACO row can never collide with a USDA one
  // (import_usda_foods.dart uses 00000000 for en and 00000001 for pt). TACO is
  // Portuguese-only, so there is no locale to key on. user_id is intentionally
  // omitted, not null: generic rows are unowned, and on the id DO UPDATE an
  // absent column is left untouched.
  String get id {
    final number16 = number.toRadixString(16).padLeft(12, '0');
    return '00000002-0000-4000-8000-$number16';
  }

  Map<String, dynamic> toRow() => {
    'id': id,
    'name': name,
    'source': FoodSource.generic.wireValue,
    'calories_per_100g': calories,
    'protein_per_100g': protein,
    'carbs_per_100g': carbs,
    'fat_per_100g': fat,
    'fiber_per_100g': fiber,
    if (category != null) 'category': category!.wireValue,
    if (preparation != null) 'preparation': preparation!.wireValue,
  };
}
