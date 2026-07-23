import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/cubit/premium_cubit.dart';
import 'package:vitta/app/cubit/premium_state.dart';
import 'package:vitta/app/domain/auth/use_cases/watch_user_id_use_case.dart';
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
      return PremiumCubit(getPremiumStatusUseCase: getPremiumStatusUseCase, purchaseService: purchaseService, watchUserIdUseCase: _userIdUseCase());
    },
    // Two emits, because the constructor starts both reads: the store answers
    // with nothing to sell, then the entitlement lands for the signed-in user.
    expect: () => [
      const PremiumState(status: PremiumStatus.free()),
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
      return PremiumCubit(getPremiumStatusUseCase: getPremiumStatusUseCase, purchaseService: purchaseService, watchUserIdUseCase: _userIdUseCase());
    },
    // Cubit.emit only de-duplicates after its first emission, so the free state
    // is delivered once even though it equals the initial one - and the failed
    // entitlement read then emits the same free state, which is de-duplicated.
    expect: () => [const PremiumState(status: PremiumStatus.free())],
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
      return PremiumCubit(getPremiumStatusUseCase: getPremiumStatusUseCase, purchaseService: purchaseService, watchUserIdUseCase: _userIdUseCase());
    },
    act: (cubit) => cubit.refresh(),
    expect: () => [
      const PremiumState(status: PremiumStatus.free()),
      const PremiumState(status: PremiumStatus(status: .active)),
    ],
  );

  // The bug this pins: the cubit is a root singleton that outlives a sign-out,
  // so reading the entitlement only at construction left the first user's
  // subscription entitling whoever signed in next on the same device.
  test('drops the previous user entitlement when another user signs in', () async {
    final getPremiumStatusUseCase = MockGetPremiumStatusUseCase();
    when(getPremiumStatusUseCase.call).thenAnswer((_) => Future.value(const Success(PremiumStatus(status: .active))));
    final purchaseService = MockPurchaseService();
    when(purchaseService.fetchOffers).thenAnswer((_) => Future.value(const []));
    final userIds = StreamController<String?>();
    addTearDown(userIds.close);
    final cubit = PremiumCubit(
      getPremiumStatusUseCase: getPremiumStatusUseCase,
      purchaseService: purchaseService,
      watchUserIdUseCase: _userIdUseCase(userIds.stream),
    );
    addTearDown(cubit.close);

    userIds.add('subscriber');
    await pumpEventQueue();
    expect(cubit.state.isPremium, isTrue);

    when(getPremiumStatusUseCase.call).thenAnswer((_) => Future.value(const Success(PremiumStatus.free())));
    userIds.add(null);
    await pumpEventQueue();
    expect(cubit.state.isPremium, isFalse);

    userIds.add('someone-else');
    await pumpEventQueue();
    expect(cubit.state.isPremium, isFalse);
  });
}

WatchUserIdUseCase _userIdUseCase([Stream<String?>? userIds]) {
  final watchUserIdUseCase = MockWatchUserIdUseCase();
  when(watchUserIdUseCase.call).thenAnswer((_) => userIds ?? Stream.value('user-1'));
  return watchUserIdUseCase;
}
