import 'package:equatable/equatable.dart';

sealed class User extends Equatable {
  const User();

  /// The display name to seed an edit field with - empty for anyone without
  /// one, so a form can bind it without pattern-matching the user type.
  String get displayNameOrEmpty => switch (this) {
    AuthenticatedUser(:final displayName?) => displayName,
    _ => '',
  };
}

class AuthenticatedUser extends User {
  const AuthenticatedUser({required this.email, this.displayName, this.avatarId, this.avatarUrl});

  final String email;

  /// The user's profile, stored on the Supabase auth user's metadata (see
  /// issue #117). All nullable: an account created before the profile flow, or
  /// one where the field was left blank, simply has none.
  final String? displayName;

  /// The avatar is a preset id (see VTAvatarCatalog) *or* an uploaded photo,
  /// never both - one is always null. Display precedence is photo, then the
  /// preset, then the name/email initial.
  final String? avatarId;
  final String? avatarUrl;

  /// What the app shows when there's neither a name nor an avatar: the first
  /// letter of the display name, else of the email.
  String? get initial {
    final source = (displayName?.trim().isNotEmpty ?? false) ? displayName!.trim() : email;
    return source.isEmpty ? null : source[0].toUpperCase();
  }

  @override
  List<Object?> get props => [email, displayName, avatarId, avatarUrl];
}

class AnonymousUser extends User {
  const AnonymousUser();

  @override
  List<Object?> get props => [];
}
