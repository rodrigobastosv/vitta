import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';

extension BuildContextNavigationExt on BuildContext {
  Future<T?> pushRoute<T extends Object?>(AppRoute route, {Object? extra}) => pushNamed<T>(route.name, extra: extra);

  void goRoute(AppRoute route, {Object? extra}) => goNamed(route.name, extra: extra);
}
