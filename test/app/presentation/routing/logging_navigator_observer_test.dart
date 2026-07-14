import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/presentation/routing/logging_navigator_observer.dart';

import '../../../fixtures/logging_fixture.dart';

void main() {
  Route<void> route(String name) => PageRouteBuilder<void>(
    settings: RouteSettings(name: name),
    pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
  );

  test('logs a push with the pushed route name', () {
    final loggingService = useMockLog();

    LoggingNavigatorObserver().didPush(route('diet'), route('home'));

    verify(() => loggingService.logNavigation(action: 'push', route: 'diet')).called(1);
  });

  test('logs a pop with the popped route name', () {
    final loggingService = useMockLog();

    LoggingNavigatorObserver().didPop(route('foodSearch'), route('diet'));

    verify(() => loggingService.logNavigation(action: 'pop', route: 'foodSearch')).called(1);
  });

  test('falls back to unknown when the route has no name', () {
    final loggingService = useMockLog();

    LoggingNavigatorObserver().didPush(
      PageRouteBuilder<void>(pageBuilder: (context, animation, secondaryAnimation) => const SizedBox()),
      null,
    );

    verify(() => loggingService.logNavigation(action: 'push', route: 'unknown')).called(1);
  });
}
