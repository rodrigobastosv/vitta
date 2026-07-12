import 'package:equatable/equatable.dart';

class AuthStatus extends Equatable {
  const AuthStatus({required this.isAnonymous, this.email});

  final bool isAnonymous;
  final String? email;

  @override
  List<Object?> get props => [isAnonymous, email];
}
