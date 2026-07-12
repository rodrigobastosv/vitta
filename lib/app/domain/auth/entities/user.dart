import 'package:equatable/equatable.dart';

sealed class User extends Equatable {
  const User();
}

class AuthenticatedUser extends User {
  const AuthenticatedUser({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

class AnonymousUser extends User {
  const AnonymousUser();

  @override
  List<Object?> get props => [];
}
