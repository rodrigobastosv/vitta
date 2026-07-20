import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/premium/paywall_extra.dart';
import 'package:vitta/app/presentation/pages/premium/paywall_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class PremiumRoute extends VTRoute {
  @override
  AppRoute get route => .premium;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => PaywallPage(extra: state.extra as PaywallExtra?);
}
