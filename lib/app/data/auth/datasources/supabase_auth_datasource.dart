import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/domain/auth/entities/auth_status.dart';

class SupabaseAuthDataSource {
  SupabaseAuthDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  AuthStatus get status =>
      AuthStatus(isAnonymous: _supabaseService.isAnonymous, email: _supabaseService.currentUserEmail);

  Future<Result<VTError, AuthStatus>> signUp({required String email, required String password}) async {
    try {
      await _supabaseService.auth.updateUser(UserAttributes(email: email, password: password));
      return Success(status);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to create account', cause: error));
    }
  }

  Future<Result<VTError, AuthStatus>> signIn({required String email, required String password}) async {
    try {
      await _supabaseService.auth.signInWithPassword(email: email, password: password);
      return Success(status);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to sign in', cause: error));
    }
  }

  Future<Result<VTError, void>> signOut() async {
    try {
      await _supabaseService.auth.signOut();
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to sign out', cause: error));
    }
  }

  Future<Result<VTError, AuthStatus>> signInAnonymously() async {
    try {
      await _supabaseService.auth.signInAnonymously();
      return Success(status);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to sign in anonymously', cause: error));
    }
  }
}
