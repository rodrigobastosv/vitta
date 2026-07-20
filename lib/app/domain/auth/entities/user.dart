import 'package:equatable/equatable.dart';

sealed class User extends Equatable {
  const User();

  String get displayNameOrEmpty => switch (this) {
    AuthenticatedUser(:final displayName?) => displayName,
    _ => '',
  };
}

class AuthenticatedUser extends User {
  const AuthenticatedUser({required this.id, required this.email, this.displayName, this.avatarId, this.avatarUrl});

  /// The Supabase auth.uid(). RevenueCat is identified with it so
  /// revenuecat-webhook can resolve a store event back to a subscriptions row.
  final String id;

  final String email;

  final String? displayName;

  final String? avatarId;
  final String? avatarUrl;

  String? get initial {
    final trimmedName = displayName?.trim();
    final source = (trimmedName != null && trimmedName.isNotEmpty) ? trimmedName : email;
    return source.isEmpty ? null : source[0].toUpperCase();
  }

  @override
  List<Object?> get props => [id, email, displayName, avatarId, avatarUrl];
}

class AnonymousUser extends User {
  const AnonymousUser();

  @override
  List<Object?> get props => [];
}
