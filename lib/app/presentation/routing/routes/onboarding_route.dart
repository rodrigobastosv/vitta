import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/onboarding/onboarding_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class OnboardingRoute extends VTRoute {
  @override
  AppRoute get route => .onboarding;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const OnboardingPage();
}
