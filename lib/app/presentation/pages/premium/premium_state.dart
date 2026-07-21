import 'package:equatable/equatable.dart';
import 'package:vitta/app/core/services/purchases/premium_offer.dart';
import 'package:vitta/app/domain/premium/entities/premium_status.dart';

class PremiumState extends Equatable {
  const PremiumState({required this.status, this.offer});

  const PremiumState.free() : status = const PremiumStatus.free(), offer = null;

  final PremiumStatus status;

  /// Null until the store answers - the paywall shows no price rather than a
  /// guessed one, since the real string is the store's to produce.
  final PremiumOffer? offer;

  bool get isPremium => status.isActive;

  bool get canPurchase => offer != null && !isPremium;

  PremiumState copyWith({PremiumStatus? status, PremiumOffer? offer}) => PremiumState(status: status ?? this.status, offer: offer ?? this.offer);

  @override
  List<Object?> get props => [status, offer];
}
