import 'package:vitta/app/domain/premium/entities/premium_feature.dart';

class PaywallExtra {
  const PaywallExtra({this.highlightedFeature});

  // The feature whose lock was tapped, so the paywall can lead with the one the
  // user actually wanted. Null when the paywall is opened from the profile,
  // where nothing was blocked.
  final PremiumFeature? highlightedFeature;
}
