import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

class AuthState extends Equatable {
  const AuthState({required this.user, this.draftAvatarId, this.draftAvatarBytes, this.draftAvatarExtension = ''});

  final User user;

  /// The avatar being composed on the sign-up/edit form, before it's saved -
  /// separate from [user], which is what's persisted. A preset id or photo
  /// bytes, never both (setting one clears the other), matching how the avatar
  /// is stored. Null/empty means no draft avatar, which falls back to the name
  /// initial when previewed.
  final String? draftAvatarId;
  final Uint8List? draftAvatarBytes;
  final String draftAvatarExtension;

  bool get hasDraftPhoto => draftAvatarBytes != null;

  /// `copyWith` can't express "clear the avatar" for the nullable fields, so
  /// clearing and replacing the draft go through the dedicated rebuilds below.
  AuthState copyWith({User? user}) => AuthState(
    user: user ?? this.user,
    draftAvatarId: draftAvatarId,
    draftAvatarBytes: draftAvatarBytes,
    draftAvatarExtension: draftAvatarExtension,
  );

  AuthState withPresetAvatar(String id) => AuthState(user: user, draftAvatarId: id);

  AuthState withPhotoAvatar({required Uint8List bytes, required String extension}) =>
      AuthState(user: user, draftAvatarBytes: bytes, draftAvatarExtension: extension);

  AuthState withoutAvatar() => AuthState(user: user);

  @override
  List<Object?> get props => [user, draftAvatarId, draftAvatarBytes, draftAvatarExtension];
}
