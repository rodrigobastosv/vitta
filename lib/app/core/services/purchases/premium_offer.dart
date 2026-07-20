import 'package:equatable/equatable.dart';

// What the paywall needs to render a purchasable plan, in the app's own terms so
// nothing above core/services/ imports purchases_flutter - the same boundary
// PickedImage draws for ImagePickerService.
//
// priceLabel is the store's own localized string ("R$ 14,90", "$4.99"), never a
// number we format: the storefront, its currency and its tax treatment are the
// store's to decide, and a price formatted here would be wrong the moment
// someone buys from a country we did not think about.
class PremiumOffer extends Equatable {
  const PremiumOffer({required this.packageId, required this.productId, required this.priceLabel});

  final String packageId;
  final String productId;
  final String priceLabel;

  @override
  List<Object?> get props => [packageId, productId, priceLabel];
}
