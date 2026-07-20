import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/premium/entities/premium_status.dart';

class PremiumState extends Equatable {
  const PremiumState({required this.status});

  const PremiumState.free() : status = const PremiumStatus.free();

  final PremiumStatus status;

  bool get isPremium => status.isActive;

  PremiumState copyWith({PremiumStatus? status}) => PremiumState(status: status ?? this.status);

  @override
  List<Object?> get props => [status];
}
