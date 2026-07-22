import 'package:flutter/material.dart';
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

    LoggingNavigatorObserver().didPop(route('addFood'), route('diet'));

    verify(() => loggingService.logNavigation(action: 'pop', route: 'addFood')).called(1);
  });

  test('falls back to unknown when an unnamed route is not a known popup', () {
    final loggingService = useMockLog();

    LoggingNavigatorObserver().didPush(PageRouteBuilder<void>(pageBuilder: (context, animation, secondaryAnimation) => const SizedBox()), null);

    verify(() => loggingService.logNavigation(action: 'push', route: 'unknown')).called(1);
  });

  testWidgets('logs an anonymous bottom sheet as bottomSheet, not unknown', (tester) async {
    final loggingService = useMockLog();
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [LoggingNavigatorObserver()],
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(context: context, builder: (_) => const SizedBox(height: 120)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    verify(() => loggingService.logNavigation(action: 'push', route: 'bottomSheet')).called(1);
  });

  testWidgets('logs an anonymous dialog as dialog, not unknown', (tester) async {
    final loggingService = useMockLog();
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [LoggingNavigatorObserver()],
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDialog<void>(context: context, builder: (_) => const AlertDialog(content: SizedBox())),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    verify(() => loggingService.logNavigation(action: 'push', route: 'dialog')).called(1);
  });
}
