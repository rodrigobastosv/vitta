import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/premium/datasources/supabase_premium_datasource.dart';
import 'package:vitta/app/domain/premium/entities/premium_status.dart';

class PremiumRepository {
  PremiumRepository({required this._supabasePremiumDataSource});

  final SupabasePremiumDataSource _supabasePremiumDataSource;

  Future<Result<VTError, PremiumStatus>> getStatus() => _supabasePremiumDataSource.getStatus();
}
