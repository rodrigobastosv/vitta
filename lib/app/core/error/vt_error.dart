import 'package:equatable/equatable.dart';

class VTError extends Equatable {
  const VTError({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}
