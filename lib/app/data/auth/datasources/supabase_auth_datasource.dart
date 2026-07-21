import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

class SupabaseAuthDataSource {
  SupabaseAuthDataSource({required this._supabaseService});

  final SupabaseService _supabaseService;

  static const _displayNameKey = 'display_name';
  static const _avatarIdKey = 'avatar_id';
  static const _avatarUrlKey = 'avatar_url';

  User get status {
    if (_supabaseService.isAnonymous) {
      return const AnonymousUser();
    }
    final metadata = _supabaseService.currentUserMetadata;
    return AuthenticatedUser(
      id: _supabaseService.currentUserId,
      email: _supabaseService.currentUserEmail ?? '',
      displayName: metadata?[_displayNameKey] as String?,
      avatarId: metadata?[_avatarIdKey] as String?,
      avatarUrl: metadata?[_avatarUrlKey] as String?,
    );
  }

  Future<Result<VTError, User>> signUp({required String email, required String password, String? displayName, String? avatarId, String? avatarUrl}) async {
    try {
      await _supabaseService.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
          data: _profileData(displayName: displayName, avatarId: avatarId, avatarUrl: avatarUrl),
        ),
      );
      return Success(status);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to create account', cause: error));
    }
  }

  Future<Result<VTError, User>> updateProfile({String? displayName, String? avatarId, String? avatarUrl}) async {
    try {
      await _supabaseService.auth.updateUser(
        UserAttributes(
          data: _profileData(displayName: displayName, avatarId: avatarId, avatarUrl: avatarUrl),
        ),
      );
      return Success(status);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to update profile', cause: error));
    }
  }

  Future<Result<VTError, String>> uploadAvatar({required Uint8List bytes, required String fileExtension}) async {
    try {
      final path = '${_supabaseService.currentUserId}/${DateTime.now().microsecondsSinceEpoch}.$fileExtension';
      final storage = _supabaseService.storage(.avatars);
      await storage.uploadBinary(path, bytes);
      return Success(storage.getPublicUrl(path));
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to upload avatar', cause: error));
    }
  }

  Map<String, dynamic> _profileData({required String? displayName, required String? avatarId, required String? avatarUrl}) => {
    _displayNameKey: displayName,
    _avatarIdKey: avatarId,
    _avatarUrlKey: avatarUrl,
  };

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

  Future<Result<VTError, void>> deleteAccount() async {
    try {
      await _supabaseService.invoke(.deleteAccount, body: const {});
      return const Success(null);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to delete account', cause: error));
    }
  }
}
