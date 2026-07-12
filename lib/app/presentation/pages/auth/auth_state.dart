import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/auth/entities/auth_status.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthLoaded extends AuthState {
  const AuthLoaded({required this.status});

  final AuthStatus status;

  @override
  List<Object?> get props => [status];
}
