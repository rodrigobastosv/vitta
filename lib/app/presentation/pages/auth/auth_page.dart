import 'package:flutter/material.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';
import 'package:vitta/app/presentation/pages/auth/widgets/auth_form.dart';
import 'package:vitta/app/presentation/pages/auth/widgets/signed_in_view.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<AuthCubit, AuthState, AuthPresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case AuthShowLoading():
            context.showLoading();
          case AuthHideLoading():
            context.hideLoading();
          case AuthActionFailed(:final message):
            context.showErrorToast(message: message);
          case AuthSignedIn():
            Navigator.of(context).pop(true);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.settingsAuthLabel)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(VTSpacing.m),
          child: switch (state.user) {
            AnonymousUser() => AuthForm(isSignUp: state.isSignUpMode, onModeChanged: cubit.setSignUpMode, onSubmit: cubit.submit),
            AuthenticatedUser(:final email) => SignedInView(email: email, onSignOut: cubit.signOut),
          },
        ),
      ),
    );
  }
}
