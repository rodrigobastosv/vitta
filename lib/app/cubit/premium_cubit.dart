import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/services/purchases/purchase_outcome.dart';
import 'package:vitta/app/core/services/purchases/purchase_service.dart';
import 'package:vitta/app/cubit/premium_state.dart';
import 'package:vitta/app/domain/premium/entities/premium_status.dart';
import 'package:vitta/app/domain/premium/use_cases/get_premium_status_use_case.dart';

// A plain Cubit provided once at the root, like AppCubit, rather than a
// PresentationCubit resolved per page: the entitlement gates affordances on
// several unrelated screens, and a factory would re-read it over the network on
// every page build and make the locks flicker in.
//
// It drives PurchaseService directly rather than through a use case, the way
// AuthCubit drives ImagePickerService and ReminderCubit drives
// NotificationService: buying is a device/store interaction, not persistence.
class PremiumCubit extends Cubit<PremiumState> {
  PremiumCubit({required this._getPremiumStatusUseCase, required this._purchaseService}) : super(const PremiumState.free()) {
    refresh();
    // Fetched at construction rather than when the paywall opens: the page has
    // no lifecycle hook of its own (VTPage owns onInit, and this cubit is the
    // root singleton), and fetchOffers returns instantly when no API key is
    // configured, so the common cost is nil and the price is there on open.
    loadOffer();
  }

  final GetPremiumStatusUseCase _getPremiumStatusUseCase;
  final PurchaseService _purchaseService;

  // A failed read leaves the user free, which is the safe direction: it locks a
  // paid feature rather than giving it away, and the Edge Function is the real
  // gate anyway. There is deliberately no error toast - a startup complaint
  // about a subscription most users do not have would be pure noise.
  Future<void> refresh() async {
    final statusResult = await _getPremiumStatusUseCase();
    final status = statusResult.when((_) => const PremiumStatus.free(), (status) => status);
    emit(state.copyWith(status: status));
  }

  // A store that cannot be reached just leaves the paywall without a price,
  // which reads as "not available right now" rather than an error the user can
  // do anything about.
  //
  // Every exit marks the offer loaded, including the failures: what the paywall
  // needs to distinguish is "still asking" from "asked", and a failed ask is
  // answered. Leaving it false on error would pulse a skeleton forever - the
  // same trailing-guard reasoning the history cubits' failure path follows.
  Future<void> loadOffer() async {
    try {
      final offers = await _purchaseService.fetchOffers();
      if (offers.isEmpty) {
        emit(state.copyWith(isOfferLoaded: true));
        return;
      }
      emit(state.copyWith(offer: offers.first, isOfferLoaded: true));
    } on Exception catch (error) {
      Log.action('premium_offer_unavailable', data: {'error': error.toString()});
      emit(state.copyWith(isOfferLoaded: true));
    }
  }

  /// Returns whether the purchase completed, so the page can pop or stay put.
  /// Cancelling is not a failure and reports false without an error.
  ///
  /// [userId] is the Supabase auth.uid(). RevenueCat is identified with it
  /// immediately before buying rather than at sign-in: identity only matters for
  /// attributing a purchase, and doing it here keeps AuthCubit out of the store
  /// entirely. Without it the purchase carries RevenueCat's anonymous id, which
  /// revenuecat-webhook deliberately ignores - so the entitlement would never
  /// reach a subscriptions row.
  Future<bool> purchase({required String userId}) async {
    final offer = state.offer;
    if (offer == null) {
      return false;
    }
    await _purchaseService.logIn(userId);
    final outcome = await _purchaseService.purchase(offer.packageId);
    if (outcome == PurchaseOutcome.cancelled) {
      return false;
    }
    Log.action('premium_purchased', data: {'product_id': offer.productId});
    _entitleOptimistically();
    return true;
  }

  /// Returns whether the store found a subscription to restore. Identifies the
  /// user first for the same reason [purchase] does — a restore has to land on
  /// the Supabase user, not on an anonymous store identity.
  Future<bool> restore({required String userId}) async {
    await _purchaseService.logIn(userId);
    final isEntitled = await _purchaseService.restore();
    if (!isEntitled) {
      return false;
    }
    Log.action('premium_restored');
    _entitleOptimistically();
    return true;
  }

  // The store has confirmed the purchase, but subscriptions is only written when
  // RevenueCat's webhook lands - which is a round trip away. Waiting for it would
  // leave the user staring at a locked feature they just paid for, so the
  // entitlement is granted locally at once and the server read follows to make
  // it durable. If that read disagrees it wins, and the scans would fail server
  // side anyway: this is optimism about timing, not about entitlement.
  void _entitleOptimistically() {
    emit(
      state.copyWith(
        status: PremiumStatus(status: .active, productId: state.offer?.productId),
      ),
    );
    unawaited(refresh());
  }
}
