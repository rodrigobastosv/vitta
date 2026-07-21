import 'package:equatable/equatable.dart';
import 'package:vitta/app/core/services/purchases/premium_period.dart';

// What the paywall needs to render a purchasable plan, in the app's own terms so
// nothing above core/services/ imports purchases_flutter - the same boundary
// PickedImage draws for ImagePickerService.
//
// priceLabel is the store's own localized string ("R$ 14,90", "$4.99"), never a
// number we format: the storefront, its currency and its tax treatment are the
// store's to decide, and a price formatted here would be wrong the moment
// someone buys from a country we did not think about.
class PremiumOffer extends Equatable {
  const PremiumOffer({required this.packageId, required this.productId, required this.priceLabel, this.period});

  final String packageId;
  final String productId;
  final String priceLabel;

  /// Null when the store describes the package as custom or unknown, in which
  /// case the paywall names the price without claiming a period rather than
  /// guessing one — the same "return null rather than guess" rule the scan
  /// prompts follow, and for the same reason: a wrong period is a wrong claim
  /// about what the user is being charged.
  final PremiumPeriod? period;

  @override
  List<Object?> get props => [packageId, productId, priceLabel, period];
}
