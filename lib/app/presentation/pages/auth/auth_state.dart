import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

class AuthState extends Equatable {
  const AuthState({required this.user, this.isSignUpMode = true});

  final User user;
  final bool isSignUpMode;

  AuthState copyWith({User? user, bool? isSignUpMode}) =>
      AuthState(user: user ?? this.user, isSignUpMode: isSignUpMode ?? this.isSignUpMode);

  @override
  List<Object?> get props => [user, isSignUpMode];
}
