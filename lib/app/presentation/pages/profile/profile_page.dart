import 'package:flutter/material.dart';
import 'package:vitta/app/core/error/error_dialog_extensions.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
          case AuthSignedIn():
            break;
          case AuthActionFailed(:final message):
            context.showErrorDialog(message: message);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.profileTitle)),
        body: ListView(
          padding: const EdgeInsets.all(VTSpacing.m),
          children: [
            switch (state.user) {
              AnonymousUser() => _AnonymousHeader(
                onSignIn: () async {
                  await context.pushRoute(.auth);
                  cubit.refreshUser();
                },
              ),
              AuthenticatedUser(:final email) => _SignedInHeader(email: email, onSignOut: cubit.signOut),
            },
            const VTGap.l(),
            VTCard(
              padding: EdgeInsets.zero,
              onTap: () => context.pushRoute(.macroGoals),
              child: ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(l10n.macroGoalsTitle),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const VTGap.m(),
            VTCard(
              padding: EdgeInsets.zero,
              onTap: () => context.pushRoute(.settings),
              child: ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(l10n.settingsTitle),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedInHeader extends StatelessWidget {
  const _SignedInHeader({required this.email, required this.onSignOut});

  final String email;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  email.isEmpty ? '?' : email[0].toUpperCase(),
                  style: VTTextStyles.title(context).copyWith(color: colorScheme.onPrimaryContainer),
                ),
              ),
              const VTGap.m(),
              Expanded(child: Text(email, style: VTTextStyles.title(context))),
            ],
          ),
          const VTGap.m(),
          OutlinedButton(onPressed: onSignOut, child: Text(l10n.authLogoutAction)),
        ],
      ),
    );
  }
}

class _AnonymousHeader extends StatelessWidget {
  const _AnonymousHeader({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return VTCard(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant),
              ),
              const VTGap.m(),
              Expanded(child: Text(l10n.authAnonymousMessage)),
            ],
          ),
          const VTGap.m(),
          VTPrimaryButton(label: l10n.profileSignInAction, onPressed: onSignIn),
        ],
      ),
    );
  }
}
