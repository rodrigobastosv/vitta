import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/services/purchases/premium_offer.dart';
import 'package:vitta/app/core/services/purchases/purchase_outcome.dart';
import 'package:vitta/app/cubit/premium_cubit.dart';
import 'package:vitta/app/domain/premium/entities/premium_status.dart';
import 'package:vitta/app/presentation/pages/premium/premium_state.dart';

import '../../mocks/services_mocks.dart';
import '../../mocks/use_cases_mocks.dart';

const _offer = PremiumOffer(packageId: r'$rc_monthly', productId: 'vitta_premium_monthly', priceLabel: r'R$ 14,90');

MockGetPremiumStatusUseCase _freeStatusUseCase() {
  final getPremiumStatusUseCase = MockGetPremiumStatusUseCase();
  when(getPremiumStatusUseCase.call).thenAnswer((_) => Future.value(const Success(PremiumStatus.free())));
  return getPremiumStatusUseCase;
}

void main() {
  blocTest<PremiumCubit, PremiumState>(
    'exposes the offer the store returned, price string and all',
    build: () {
      final purchaseService = MockPurchaseService();
      when(purchaseService.fetchOffers).thenAnswer((_) => Future.value(const [_offer]));
      return PremiumCubit(getPremiumStatusUseCase: _freeStatusUseCase(), purchaseService: purchaseService);
    },
    verify: (cubit) {
      expect(cubit.state.offer, _offer);
      expect(cubit.state.canPurchase, isTrue);
    },
  );

  // The price is the store's own localized string; an unreachable store leaves
  // it null so the paywall says "unavailable" rather than naming a figure.
  blocTest<PremiumCubit, PremiumState>(
    'leaves the offer null when the store returns nothing',
    build: () {
      final purchaseService = MockPurchaseService();
      when(purchaseService.fetchOffers).thenAnswer((_) => Future.value(const []));
      return PremiumCubit(getPremiumStatusUseCase: _freeStatusUseCase(), purchaseService: purchaseService);
    },
    verify: (cubit) {
      expect(cubit.state.offer, isNull);
      expect(cubit.state.canPurchase, isFalse);
    },
  );

  test('identifies the RevenueCat user before buying, or the webhook cannot resolve the purchase', () async {
    final purchaseService = MockPurchaseService();
    when(purchaseService.fetchOffers).thenAnswer((_) => Future.value(const [_offer]));
    when(() => purchaseService.logIn(any())).thenAnswer((_) => Future.value());
    when(() => purchaseService.purchase(any())).thenAnswer((_) => Future.value(PurchaseOutcome.purchased));
    final cubit = PremiumCubit(getPremiumStatusUseCase: _freeStatusUseCase(), purchaseService: purchaseService);
    await Future<void>.delayed(Duration.zero);

    await cubit.purchase(userId: 'user-1');

    verifyInOrder([() => purchaseService.logIn('user-1'), () => purchaseService.purchase(r'$rc_monthly')]);
  });

  test('entitles immediately on purchase rather than waiting for the webhook', () async {
    final purchaseService = MockPurchaseService();
    when(purchaseService.fetchOffers).thenAnswer((_) => Future.value(const [_offer]));
    when(() => purchaseService.logIn(any())).thenAnswer((_) => Future.value());
    when(() => purchaseService.purchase(any())).thenAnswer((_) => Future.value(PurchaseOutcome.purchased));
    final cubit = PremiumCubit(getPremiumStatusUseCase: _freeStatusUseCase(), purchaseService: purchaseService);
    await Future<void>.delayed(Duration.zero);

    final hasPurchased = await cubit.purchase(userId: 'user-1');

    expect(hasPurchased, isTrue);
    expect(cubit.state.isPremium, isTrue);
  });

  // Backing out of the store sheet is a deliberate action, not an error - it
  // must not entitle, and it must not read as a failure to the page.
  test('a cancelled purchase reports false and does not entitle', () async {
    final purchaseService = MockPurchaseService();
    when(purchaseService.fetchOffers).thenAnswer((_) => Future.value(const [_offer]));
    when(() => purchaseService.logIn(any())).thenAnswer((_) => Future.value());
    when(() => purchaseService.purchase(any())).thenAnswer((_) => Future.value(PurchaseOutcome.cancelled));
    final cubit = PremiumCubit(getPremiumStatusUseCase: _freeStatusUseCase(), purchaseService: purchaseService);
    await Future<void>.delayed(Duration.zero);

    final hasPurchased = await cubit.purchase(userId: 'user-1');

    expect(hasPurchased, isFalse);
    expect(cubit.state.isPremium, isFalse);
  });

  test('restoring nothing leaves the user free', () async {
    final purchaseService = MockPurchaseService();
    when(purchaseService.fetchOffers).thenAnswer((_) => Future.value(const []));
    when(() => purchaseService.logIn(any())).thenAnswer((_) => Future.value());
    when(purchaseService.restore).thenAnswer((_) => Future.value(false));
    final cubit = PremiumCubit(getPremiumStatusUseCase: _freeStatusUseCase(), purchaseService: purchaseService);
    await Future<void>.delayed(Duration.zero);

    expect(await cubit.restore(userId: 'user-1'), isFalse);
    expect(cubit.state.isPremium, isFalse);
  });

  test('a successful restore entitles', () async {
    final purchaseService = MockPurchaseService();
    when(purchaseService.fetchOffers).thenAnswer((_) => Future.value(const []));
    when(() => purchaseService.logIn(any())).thenAnswer((_) => Future.value());
    when(purchaseService.restore).thenAnswer((_) => Future.value(true));
    final cubit = PremiumCubit(getPremiumStatusUseCase: _freeStatusUseCase(), purchaseService: purchaseService);
    await Future<void>.delayed(Duration.zero);

    expect(await cubit.restore(userId: 'user-1'), isTrue);
    expect(cubit.state.isPremium, isTrue);
  });
}
