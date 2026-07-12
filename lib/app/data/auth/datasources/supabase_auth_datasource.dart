import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

class SupabaseAuthDataSource {
  SupabaseAuthDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  User get status =>
      _supabaseService.isAnonymous ? const AnonymousUser() : AuthenticatedUser(email: _supabaseService.currentUserEmail ?? '');

  Future<Result<VTError, User>> signUp({required String email, required String password}) async {
    try {
      await _supabaseService.auth.updateUser(UserAttributes(email: email, password: password));
      return Success(status);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to create account', cause: error));
    }
  }

  Future<Result<VTError, User>> signIn({required String email, required String password}) async {
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

  Future<Result<VTError, User>> signInAnonymously() async {
    try {
      await _supabaseService.auth.signInAnonymously();
      return Success(status);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to sign in anonymously', cause: error));
    }
  }
}
