import 'package:go_router/go_router.dart';
import 'package:vitta/app/domain/onboarding/use_cases/has_seen_onboarding_use_case.dart';
import 'package:vitta/app/presentation/pages/home/home_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class HomeRoute extends VTRoute {
  HomeRoute({required this._hasSeenOnboardingUseCase});

  final HasSeenOnboardingUseCase _hasSeenOnboardingUseCase;

  @override
  AppRoute get route => .home;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => const HomePage();

  @override
  GoRouterRedirect get redirect => (context, state) => _hasSeenOnboardingUseCase() ? null : AppRoute.onboarding.path;
}
