import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/auth/datasources/supabase_auth_datasource.dart';
import 'package:vitta/app/domain/auth/entities/auth_status.dart';

class AuthRepository {
  AuthRepository({required this._supabaseAuthDataSource});

  final SupabaseAuthDataSource _supabaseAuthDataSource;

  AuthStatus get status => _supabaseAuthDataSource.status;

  Future<Result<VTError, AuthStatus>> signUp({required String email, required String password}) =>
      _supabaseAuthDataSource.signUp(email: email, password: password);

  Future<Result<VTError, AuthStatus>> signIn({required String email, required String password}) =>
      _supabaseAuthDataSource.signIn(email: email, password: password);

  Future<Result<VTError, void>> signOut() => _supabaseAuthDataSource.signOut();

  Future<Result<VTError, AuthStatus>> signInAnonymously() => _supabaseAuthDataSource.signInAnonymously();
}
