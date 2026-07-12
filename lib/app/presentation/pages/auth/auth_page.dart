import 'package:flutter/material.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';
import 'package:vitta/app/presentation/pages/auth/widgets/auth_form.dart';
import 'package:vitta/app/presentation/pages/auth/widgets/signed_in_view.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key, this.initialIsSignUp = true});

  final bool initialIsSignUp;

  @override
  Widget build(BuildContext context) => VTPage<AuthCubit, AuthState, AuthPresentationEvent>(
    onPresentation: (context, event) {
      switch (event) {
        case AuthShowLoading():
          context.showLoading();
        case AuthHideLoading():
          context.hideLoading();
        case AuthActionFailed(:final message):
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        case AuthSignedIn():
          Navigator.of(context).pop(true);
      }
    },
    builder: (context, cubit, state) {
      final l10n = AppLocalizations.of(context);
      final status = (state as AuthLoaded).status;
      return Scaffold(
        appBar: AppBar(title: Text(l10n.settingsAuthLabel)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(VTSpacing.m),
          child: status.isAnonymous
              ? AuthForm(initialIsSignUp: initialIsSignUp, onSignUp: cubit.signUp, onSignIn: cubit.signIn)
              : SignedInView(email: status.email ?? '', onSignOut: cubit.signOut),
        ),
      );
    },
  );
}
