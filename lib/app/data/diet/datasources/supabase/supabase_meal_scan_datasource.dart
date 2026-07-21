import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitta/app/core/error/premium_required_error.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_function_exception_extensions.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/domain/diet/entities/scanned_meal.dart';

class SupabaseMealScanDataSource {
  SupabaseMealScanDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  Future<Result<VTError, ScannedMeal>> scanMeal({required String imagePath}) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final response = await _supabaseService.invoke(.scanMeal, body: {'imageBase64': base64Encode(bytes), 'fileExtension': imagePath.split('.').last});
      return Success(ScannedMeal.fromMap(response.data as Map<String, dynamic>));
    } on FunctionException catch (error) {
      if (error.isPremiumRequired) {
        return Failure(PremiumRequiredError(cause: error));
      }
      return Failure(VTError(message: 'Failed to scan meal', cause: error));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to scan meal', cause: error));
    }
  }
}
