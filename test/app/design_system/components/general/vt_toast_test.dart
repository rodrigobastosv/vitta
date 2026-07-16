import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_severity.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> settleToast(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> pumpToast(
  WidgetTester tester, {
  required void Function(BuildContext context) show,
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: brightness == Brightness.light ? VTTheme.light : VTTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(onPressed: () => show(context), child: const Text('open')),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await settleToast(tester);
}

Color discColorOf(WidgetTester tester) {
  final disc = tester.widget<Container>(find.ancestor(of: find.byType(Icon).first, matching: find.byType(Container)).first);
  return (disc.decoration! as BoxDecoration).color!;
}

Color iconColorOf(WidgetTester tester) => tester.widget<Icon>(find.byType(Icon).first).color!;

Color cardColorOf(WidgetTester tester) =>
    tester.widget<Material>(find.ancestor(of: find.byType(Icon).first, matching: find.byType(Material)).first).color!;

Color textColorOf(WidgetTester tester, String text) => tester.widget<Text>(find.text(text)).style!.color!;

double contrastRatio(Color a, Color b) {
  assert(a.a == 1.0 && b.a == 1.0, 'composite translucent colours before measuring them');
  final luminances = [a.computeLuminance(), b.computeLuminance()];
  return (luminances.reduce(math.max) + 0.05) / (luminances.reduce(math.min) + 0.05);
}

void main() {
  testWidgets('an error toast carries its retry as an action, and clears itself when taken', (tester) async {
    var retried = 0;
    await pumpToast(
      tester,
      show: (context) => context.showErrorToast(message: 'Could not load', onRetry: () => retried++),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Could not load'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await settleToast(tester);

    expect(retried, 1);
    expect(find.text('Could not load'), findsNothing);
  });

  testWidgets('an error with nothing to retry shows no action at all', (tester) async {
    await pumpToast(tester, show: (context) => context.showErrorToast(message: 'Failed to sign in'));

    expect(find.text('Failed to sign in'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('a warning never offers retry - the same form fails the same way', (tester) async {
    await pumpToast(tester, show: (context) => context.showWarningToast(message: 'Fill in the name.'));

    expect(find.text('Almost there'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('a caller with a better title than the default gets to use it', (tester) async {
    await pumpToast(
      tester,
      show: (context) => context.showWarningToast(message: 'Enter the values manually.', title: 'Could not read the label'),
    );

    expect(find.text('Could not read the label'), findsOneWidget);
    expect(find.text('Almost there'), findsNothing);
  });

  testWidgets('a failure stays up longer than a success - it is not free to miss', (tester) async {
    await pumpToast(
      tester,
      show: (context) => context.showToast(title: 'Logged', message: 'Added to lunch'),
    );
    final success = tester.widget<SnackBar>(find.byType(SnackBar)).duration;

    await pumpToast(tester, show: (context) => context.showErrorToast(message: 'Could not load'));
    final failure = tester.widget<SnackBar>(find.byType(SnackBar)).duration;

    expect(failure, greaterThan(success));
  });

  for (final severity in VTSeverity.values) {
    for (final brightness in Brightness.values) {
      testWidgets('${severity.name} on ${brightness.name} reads against the page it floats over', (tester) async {
        await pumpToast(tester, show: showFor(severity), brightness: brightness);

        final theme = brightness == Brightness.light ? VTTheme.light : VTTheme.dark;
        expect(cardColorOf(tester), isNot(theme.colorScheme.surface));
        expect(cardColorOf(tester), isNot(theme.scaffoldBackgroundColor));
      });

      testWidgets('${severity.name} on ${brightness.name} stays legible on its own card', (tester) async {
        await pumpToast(tester, show: showFor(severity), brightness: brightness);

        final card = cardColorOf(tester);
        final disc = Color.alphaBlend(discColorOf(tester), card);
        expect(contrastRatio(iconColorOf(tester), disc), greaterThanOrEqualTo(4.5));
        expect(contrastRatio(textColorOf(tester, titleFor(severity)), card), greaterThanOrEqualTo(4.5));
      });
    }
  }
}

void Function(BuildContext) showFor(VTSeverity severity) => switch (severity) {
  .success => (context) => context.showToast(title: 'Logged', message: 'Added to lunch'),
  .warning => (context) => context.showWarningToast(message: 'Fill in the name.'),
  .error => (context) => context.showErrorToast(message: 'Could not load'),
};

String titleFor(VTSeverity severity) => switch (severity) {
  .success => 'Logged',
  .warning => 'Almost there',
  .error => 'Something went wrong',
};
