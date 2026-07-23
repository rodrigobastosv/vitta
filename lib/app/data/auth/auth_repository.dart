import 'dart:typed_data';

import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/auth/datasources/supabase_auth_datasource.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

class AuthRepository {
  AuthRepository({required this._supabaseAuthDataSource});

  final SupabaseAuthDataSource _supabaseAuthDataSource;

  User get status => _supabaseAuthDataSource.status;

  Stream<String?> get userIdChanges => _supabaseAuthDataSource.userIdChanges;

  Future<Result<VTError, User>> signUp({required String email, required String password, String? displayName, String? avatarId, String? avatarUrl}) =>
      _supabaseAuthDataSource.signUp(email: email, password: password, displayName: displayName, avatarId: avatarId, avatarUrl: avatarUrl);

  Future<Result<VTError, User>> updateProfile({String? displayName, String? avatarId, String? avatarUrl}) =>
      _supabaseAuthDataSource.updateProfile(displayName: displayName, avatarId: avatarId, avatarUrl: avatarUrl);

  Future<Result<VTError, String>> uploadAvatar({required Uint8List bytes, required String fileExtension}) =>
      _supabaseAuthDataSource.uploadAvatar(bytes: bytes, fileExtension: fileExtension);

  Future<Result<VTError, User>> signIn({required String email, required String password}) => _supabaseAuthDataSource.signIn(email: email, password: password);

  Future<Result<VTError, void>> signOut() => _supabaseAuthDataSource.signOut();

  Future<Result<VTError, User>> signInAnonymously() => _supabaseAuthDataSource.signInAnonymously();

  Future<Result<VTError, void>> deleteAccount() => _supabaseAuthDataSource.deleteAccount();
}
