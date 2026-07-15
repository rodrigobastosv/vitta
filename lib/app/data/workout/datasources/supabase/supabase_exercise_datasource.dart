import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/core/text/accent_folding.dart';
import 'package:vitta/app/domain/workout/entities/exercise.dart';
import 'package:vitta/app/domain/workout/entities/muscle_group.dart';

class SupabaseExerciseDataSource {
  SupabaseExerciseDataSource({required this._supabaseService});

  static const _searchLimit = 50;

  final SupabaseService _supabaseService;

  Future<Result<VTError, List<Exercise>>> searchCatalog({required String query, MuscleGroup? muscleGroup}) async {
    try {
      var request = _supabaseService.from(.exercises).select();
      if (query.isNotEmpty) {
        request = request.ilike('search_text', '%${AccentFolding.fold(query)}%');
      }
      if (muscleGroup != null) {
        request = request.contains('primary_muscles', [muscleGroup.wireValue]);
      }
      final rows = await request.order('times_logged', ascending: false).order('id', ascending: true).limit(_searchLimit);
      return Success(rows.map(Exercise.fromMap).toList());
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to search exercises for "$query"', cause: error));
    }
  }

  Future<Result<VTError, Exercise>> getExercise({required String exerciseId}) async {
    try {
      final row = await _supabaseService.from(.exercises).select().eq('id', exerciseId).single();
      return Success(Exercise.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load exercise $exerciseId', cause: error));
    }
  }
}
