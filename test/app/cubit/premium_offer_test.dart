import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/services/purchases/premium_offer.dart';
import 'package:vitta/app/core/services/purchases/premium_period.dart';
import 'package:vitta/app/cubit/premium_cubit.dart';
import 'package:vitta/app/cubit/premium_state.dart';
import 'package:vitta/app/domain/premium/entities/premium_status.dart';

import '../../mocks/services_mocks.dart';
import '../../mocks/use_cases_mocks.dart';

void main() {
  test('the initial state has not heard from the store yet', () {
    expect(const PremiumState.free().isOfferLoaded, isFalse);
  });

  // A state built with data is by definition answered - only the cubit's
  // synthetic starting value is not. Defaulting the other way would make every
  // widget test that constructs a state render a skeleton.
  test('a state constructed directly counts as answered', () {
    expect(const PremiumState(status: PremiumStatus.free()).isOfferLoaded, isTrue);
  });

  blocTest<PremiumCubit, PremiumState>(
    'marks the offer answered once the store reports a plan',
    build: () {
      final getPremiumStatusUseCase = MockGetPremiumStatusUseCase();
      when(getPremiumStatusUseCase.call).thenAnswer((_) => Future.value(const Success(PremiumStatus.free())));
      final purchaseService = MockPurchaseService();
      when(purchaseService.fetchOffers).thenAnswer(
        (_) => Future.value(const [
          PremiumOffer(packageId: r'$rc_monthly', productId: 'vitta_premium_monthly', priceLabel: r'$4.99', period: .monthly),
        ]),
      );
      return PremiumCubit(getPremiumStatusUseCase: getPremiumStatusUseCase, purchaseService: purchaseService);
    },
    verify: (cubit) {
      expect(cubit.state.isOfferLoaded, isTrue);
      expect(cubit.state.offer?.period, PremiumPeriod.monthly);
    },
  );

  // The failure paths matter more than the happy one: leaving isOfferLoaded
  // false on an error would pulse the skeleton forever, which is the trailing
  // guard the history cubits' failure path exists for.
  blocTest<PremiumCubit, PremiumState>(
    'marks the offer answered when the store has nothing to sell',
    build: () {
      final getPremiumStatusUseCase = MockGetPremiumStatusUseCase();
      when(getPremiumStatusUseCase.call).thenAnswer((_) => Future.value(const Success(PremiumStatus.free())));
      final purchaseService = MockPurchaseService();
      when(purchaseService.fetchOffers).thenAnswer((_) => Future.value(const []));
      return PremiumCubit(getPremiumStatusUseCase: getPremiumStatusUseCase, purchaseService: purchaseService);
    },
    verify: (cubit) {
      expect(cubit.state.isOfferLoaded, isTrue);
      expect(cubit.state.offer, isNull);
    },
  );

  blocTest<PremiumCubit, PremiumState>(
    'marks the offer answered when the store call throws',
    build: () {
      final getPremiumStatusUseCase = MockGetPremiumStatusUseCase();
      when(getPremiumStatusUseCase.call).thenAnswer((_) => Future.value(const Success(PremiumStatus.free())));
      final purchaseService = MockPurchaseService();
      when(purchaseService.fetchOffers).thenThrow(Exception('store unreachable'));
      return PremiumCubit(getPremiumStatusUseCase: getPremiumStatusUseCase, purchaseService: purchaseService);
    },
    verify: (cubit) {
      expect(cubit.state.isOfferLoaded, isTrue);
      expect(cubit.state.offer, isNull);
    },
  );
}
