import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:vitta/app/core/env/env.dart';
import 'package:vitta/app/core/services/purchases/premium_offer.dart';
import 'package:vitta/app/core/services/purchases/premium_period.dart';
import 'package:vitta/app/core/services/purchases/purchase_outcome.dart';

// The entitlement identifier configured in RevenueCat. A typo here reads as
// "bought successfully but still not premium", so it is a constant rather than
// a string repeated at each call site.
const _entitlementId = 'premium';

/// Thin adapter over `purchases_flutter` so nothing above core/services/ imports
/// the package directly — the same boundary NotificationService, HealthService
/// and ImagePickerService establish. It speaks the app's own PremiumOffer and
/// PurchaseOutcome rather than RevenueCat's Package and PurchaseResult.
class PurchaseService {
  bool _isConfigured = false;

  // Fetched Packages, keyed by the packageId handed out on PremiumOffer. The
  // SDK will only purchase a Package it produced, so the object has to be kept
  // — but it is kept here rather than leaked upward.
  final Map<String, Package> _packages = {};

  /// Whether purchases are available at all. False when no API key is
  /// configured, which is a legitimate build (see Env.revenueCatApiKey) - the
  /// paywall then shows no price instead of the app failing to launch.
  bool get isAvailable => _isConfigured;

  Future<void> init() async {
    if (_isConfigured || Env.revenueCatApiKey.isEmpty) {
      return;
    }
    await Purchases.configure(PurchasesConfiguration(Env.revenueCatApiKey));
    _isConfigured = true;
  }

  // Ties purchases to the Supabase user, which is what lets revenuecat-webhook
  // resolve an event back to a subscriptions row. Without it a purchase carries
  // RevenueCat's own anonymous id and the webhook deliberately ignores it.
  Future<void> logIn(String userId) async {
    if (!_isConfigured) {
      return;
    }
    await Purchases.logIn(userId);
  }

  // Never throws, because signing out of the app must not depend on the store
  // being reachable — and the most common case here is not an error at all:
  // logIn only runs at purchase time, so a user who never subscribed still has
  // RevenueCat's anonymous identity, which logOut reports as
  // logOutWithAnonymousUserError. There is already no identity to shed.
  Future<void> logOut() async {
    if (!_isConfigured) {
      return;
    }
    try {
      await Purchases.logOut();
    } on PlatformException {
      return;
    }
  }

  Future<List<PremiumOffer>> fetchOffers() async {
    if (!_isConfigured) {
      return const [];
    }
    final offerings = await Purchases.getOfferings();
    final packages = offerings.current?.availablePackages ?? const <Package>[];
    _packages
      ..clear()
      ..addEntries(packages.map((package) => MapEntry(package.identifier, package)));
    return packages
        .map(
          (package) => PremiumOffer(
            packageId: package.identifier,
            productId: package.storeProduct.identifier,
            // The store's own localized string, never a number formatted here.
            priceLabel: package.storeProduct.priceString,
            period: _periodOf(package.packageType),
          ),
        )
        .toList();
  }

  // custom and unknown map to null rather than to a default: the paywall states
  // the period it is given, so guessing "monthly" here would put a false claim
  // about the charge on the most scrutinised screen in the app.
  PremiumPeriod? _periodOf(PackageType type) => switch (type) {
    PackageType.weekly => PremiumPeriod.weekly,
    PackageType.monthly => PremiumPeriod.monthly,
    PackageType.twoMonth => PremiumPeriod.twoMonth,
    PackageType.threeMonth => PremiumPeriod.threeMonth,
    PackageType.sixMonth => PremiumPeriod.sixMonth,
    PackageType.annual => PremiumPeriod.annual,
    PackageType.lifetime => PremiumPeriod.lifetime,
    PackageType.custom || PackageType.unknown => null,
  };

  Future<PurchaseOutcome> purchase(String packageId) async {
    final package = _packages[packageId];
    if (package == null) {
      throw StateError('No package $packageId — fetchOffers must run first');
    }
    try {
      await Purchases.purchase(PurchaseParams.package(package));
      return .purchased;
    } on PlatformException catch (error) {
      if (PurchasesErrorHelper.getErrorCode(error) == .purchaseCancelledError) {
        return .cancelled;
      }
      rethrow;
    }
  }

  /// Whether the store considers the user entitled after restoring. The
  /// subscriptions table stays the source of truth — this only reports what the
  /// store just said, so the app can react before the webhook lands.
  Future<bool> restore() async {
    if (!_isConfigured) {
      return false;
    }
    final customerInfo = await Purchases.restorePurchases();
    return customerInfo.entitlements.active.containsKey(_entitlementId);
  }
}
