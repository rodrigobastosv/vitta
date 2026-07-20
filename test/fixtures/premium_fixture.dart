import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/cubit/premium_cubit.dart';
import 'package:vitta/app/domain/premium/entities/premium_status.dart';

import '../mocks/use_cases_mocks.dart';

// PremiumCubit is provided once at the root in main.dart, so any widget test
// that pumps a page gating on it has to stand that provider up too. It stubs, so
// it lives here rather than in CubitsFactories - and it has to stub, because the
// cubit reads its use case from its own constructor.
PremiumCubit buildTestPremiumCubit({bool isPremium = false}) {
  final getPremiumStatusUseCase = MockGetPremiumStatusUseCase();
  when(getPremiumStatusUseCase.call).thenAnswer(
    (_) => Future.value(
      Success(isPremium ? const PremiumStatus(status: .active, productId: 'vitta_premium_monthly') : const PremiumStatus.free()),
    ),
  );
  return PremiumCubit(getPremiumStatusUseCase: getPremiumStatusUseCase);
}

Widget withTestPremium(Widget child, {bool isPremium = false}) =>
    BlocProvider<PremiumCubit>(create: (_) => buildTestPremiumCubit(isPremium: isPremium), child: child);

// For a test that pumps the real VittaApp: it resolves PremiumCubit out of DI,
// where the registered one would reach a mocked SupabaseService and blow up.
void registerTestPremiumCubit({bool isPremium = false}) {
  if (G.isRegistered<PremiumCubit>()) {
    G.unregister<PremiumCubit>();
  }
  G.registerLazySingleton<PremiumCubit>(() => buildTestPremiumCubit(isPremium: isPremium));
}
