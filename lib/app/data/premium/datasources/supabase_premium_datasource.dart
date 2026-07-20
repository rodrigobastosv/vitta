import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/domain/premium/entities/premium_status.dart';

class SupabasePremiumDataSource {
  SupabasePremiumDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  // No row means the user has never subscribed, which is the normal case for
  // most of the app's users - it is Success(free), never a Failure, so a free
  // user is not met with an error toast every time the status is read.
  Future<Result<VTError, PremiumStatus>> getStatus() async {
    try {
      final row = await _supabaseService
          .from(.subscriptions)
          .select()
          .eq('user_id', _supabaseService.currentUserId)
          .maybeSingle();
      return Success(row == null ? const PremiumStatus.free() : PremiumStatus.fromMap(row));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to load the subscription', cause: error));
    }
  }
}
