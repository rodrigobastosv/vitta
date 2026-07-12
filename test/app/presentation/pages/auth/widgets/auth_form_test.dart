import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/presentation/pages/auth/widgets/auth_form.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

void main() {
  Future<void> pumpAuthForm(
    WidgetTester tester, {
    required bool isSignUp,
    required AuthModeChanged onModeChanged,
    required AuthSubmitAction onSubmit,
  }) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AuthForm(isSignUp: isSignUp, onModeChanged: onModeChanged, onSubmit: onSubmit),
      ),
    ),
  );

  testWidgets('shows a validation error and does not submit for an invalid email', (tester) async {
    var submitted = false;
    await pumpAuthForm(
      tester,
      isSignUp: true,
      onModeChanged: ({required isSignUp}) {},
      onSubmit: ({required email, required password}) async => submitted = true,
    );

    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.enterText(find.byType(TextFormField).last, 'secret1');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(submitted, isFalse);
  });

  testWidgets('shows a validation error and does not submit for a short password', (tester) async {
    var submitted = false;
    await pumpAuthForm(
      tester,
      isSignUp: true,
      onModeChanged: ({required isSignUp}) {},
      onSubmit: ({required email, required password}) async => submitted = true,
    );

    await tester.enterText(find.byType(TextFormField).first, 'a@b.com');
    await tester.enterText(find.byType(TextFormField).last, 'short');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Password must be at least 6 characters.'), findsOneWidget);
    expect(submitted, isFalse);
  });

  testWidgets('submits the trimmed email and password when valid', (tester) async {
    String? submittedEmail;
    String? submittedPassword;
    await pumpAuthForm(
      tester,
      isSignUp: true,
      onModeChanged: ({required isSignUp}) {},
      onSubmit: ({required email, required password}) async {
        submittedEmail = email;
        submittedPassword = password;
      },
    );

    await tester.enterText(find.byType(TextFormField).first, ' a@b.com ');
    await tester.enterText(find.byType(TextFormField).last, 'secret1');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(submittedEmail, 'a@b.com');
    expect(submittedPassword, 'secret1');
  });

  testWidgets('tapping the sign-in chip reports the mode change', (tester) async {
    bool? reportedIsSignUp;
    await pumpAuthForm(
      tester,
      isSignUp: true,
      onModeChanged: ({required isSignUp}) => reportedIsSignUp = isSignUp,
      onSubmit: ({required email, required password}) async {},
    );

    await tester.tap(find.byType(ChoiceChip).last);
    await tester.pump();

    expect(reportedIsSignUp, isFalse);
  });
}
