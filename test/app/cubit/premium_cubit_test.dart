import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/cubit/premium_cubit.dart';
import 'package:vitta/app/cubit/premium_state.dart';
import 'package:vitta/app/domain/premium/entities/premium_status.dart';

import '../../mocks/services_mocks.dart';
import '../../mocks/use_cases_mocks.dart';

void main() {
  blocTest<PremiumCubit, PremiumState>(
    'emits the entitlement it reads on construction',
    build: () {
      final getPremiumStatusUseCase = MockGetPremiumStatusUseCase();
      when(getPremiumStatusUseCase.call).thenAnswer((_) => Future.value(const Success(PremiumStatus(status: .active, productId: 'vitta_premium_monthly'))));
      final purchaseService = MockPurchaseService();
      when(purchaseService.fetchOffers).thenAnswer((_) => Future.value(const []));
      return PremiumCubit(getPremiumStatusUseCase: getPremiumStatusUseCase, purchaseService: purchaseService);
    },
    // Two emits, because the constructor starts both reads: the entitlement
    // lands first, then the store answers with nothing to sell.
    expect: () => [
      const PremiumState(
        status: PremiumStatus(status: .active, productId: 'vitta_premium_monthly'),
        isOfferLoaded: false,
      ),
      const PremiumState(
        status: PremiumStatus(status: .active, productId: 'vitta_premium_monthly'),
      ),
    ],
    verify: (cubit) => expect(cubit.state.isPremium, isTrue),
  );

  // The safe direction is locking a paid feature, not giving it away - and the
  // Edge Function refuses the call regardless of what the client believes.
  blocTest<PremiumCubit, PremiumState>(
    'leaves the user free when the entitlement cannot be read',
    build: () {
      final getPremiumStatusUseCase = MockGetPremiumStatusUseCase();
      when(getPremiumStatusUseCase.call).thenAnswer((_) => Future.value(const Failure(VTError(message: 'offline'))));
      final purchaseService = MockPurchaseService();
      when(purchaseService.fetchOffers).thenAnswer((_) => Future.value(const []));
      return PremiumCubit(getPremiumStatusUseCase: getPremiumStatusUseCase, purchaseService: purchaseService);
    },
    // Cubit.emit only de-duplicates after its first emission, so the free state
    // is delivered once even though it equals the initial one.
    expect: () => [const PremiumState.free(), const PremiumState(status: PremiumStatus.free())],
    verify: (cubit) => expect(cubit.state.isPremium, isFalse),
  );

  blocTest<PremiumCubit, PremiumState>(
    'refresh picks up a subscription that became active',
    build: () {
      final getPremiumStatusUseCase = MockGetPremiumStatusUseCase();
      var isSubscribed = false;
      when(getPremiumStatusUseCase.call).thenAnswer((_) {
        final status = isSubscribed ? const PremiumStatus(status: .active) : const PremiumStatus.free();
        isSubscribed = true;
        return Future.value(Success(status));
      });
      final purchaseService = MockPurchaseService();
      when(purchaseService.fetchOffers).thenAnswer((_) => Future.value(const []));
      return PremiumCubit(getPremiumStatusUseCase: getPremiumStatusUseCase, purchaseService: purchaseService);
    },
    act: (cubit) => cubit.refresh(),
    expect: () => [
      const PremiumState.free(),
      const PremiumState(status: PremiumStatus.free()),
      const PremiumState(status: PremiumStatus(status: .active)),
    ],
  );
}
