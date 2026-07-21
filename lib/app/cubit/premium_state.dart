import 'package:equatable/equatable.dart';
import 'package:vitta/app/core/services/purchases/premium_offer.dart';
import 'package:vitta/app/domain/premium/entities/premium_status.dart';

class PremiumState extends Equatable {
  const PremiumState({required this.status, this.offer, this.isOfferLoaded = true});

  const PremiumState.free() : status = const PremiumStatus.free(), offer = null, isOfferLoaded = false;

  final PremiumStatus status;

  /// Null until the store answers - the paywall shows no price rather than a
  /// guessed one, since the real string is the store's to produce.
  final PremiumOffer? offer;

  /// Whether the store has ever answered, which is not the same fact as [offer]
  /// being null - the XHistoryState.isLoaded distinction. A null offer alone
  /// conflates "still asking" with "asked, and there is nothing to sell", so the
  /// paywall showed "Subscriptions aren't available right now" for the whole
  /// round trip on every open. It never returns to false: this records whether
  /// the answer is known, not whether a request is in flight.
  ///
  /// Defaults true because a state constructed with data is by definition
  /// answered; only the cubit's synthetic starting value is not.
  final bool isOfferLoaded;

  bool get isPremium => status.isActive;

  bool get canPurchase => offer != null && !isPremium;

  PremiumState copyWith({PremiumStatus? status, PremiumOffer? offer, bool? isOfferLoaded}) =>
      PremiumState(status: status ?? this.status, offer: offer ?? this.offer, isOfferLoaded: isOfferLoaded ?? this.isOfferLoaded);

  @override
  List<Object?> get props => [status, offer, isOfferLoaded];
}
