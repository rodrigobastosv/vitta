import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitta/app/core/error/premium_required_error.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_function_exception_extensions.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/domain/diet/entities/scanned_nutrition_facts.dart';

class SupabaseNutritionScanDataSource {
  SupabaseNutritionScanDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  Future<Result<VTError, ScannedNutritionFacts>> scanLabel({required String imagePath}) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final response = await _supabaseService.invoke(
        .scanNutritionLabel,
        body: {'imageBase64': base64Encode(bytes), 'fileExtension': imagePath.split('.').last},
      );
      return Success(ScannedNutritionFacts.fromMap(response.data as Map<String, dynamic>));
    } on FunctionException catch (error) {
      if (error.isPremiumRequired) {
        return Failure(PremiumRequiredError(cause: error));
      }
      return Failure(VTError(message: 'Failed to read nutrition label', cause: error));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to read nutrition label', cause: error));
    }
  }
}
