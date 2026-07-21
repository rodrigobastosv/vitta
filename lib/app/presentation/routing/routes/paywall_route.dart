import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/paywall/paywall_extra.dart';
import 'package:vitta/app/presentation/pages/paywall/paywall_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class PremiumRoute extends VTRoute {
  @override
  AppRoute get route => .paywall;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => PaywallPage(extra: state.extra as PaywallExtra?);
}
