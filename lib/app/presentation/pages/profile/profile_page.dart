import 'package:flutter/material.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';
import 'package:vitta/app/presentation/pages/profile/widgets/profile_header.dart';
import 'package:vitta/app/presentation/pages/profile/widgets/profile_menu_tile.dart';

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
            context.showErrorToast(message: message);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.profileTitle)),
        body: ListView(
          padding: const EdgeInsets.all(VTSpacing.m),
          children: [
            switch (state.user) {
              AnonymousUser() => ProfileHeader(
                onAction: () async {
                  await context.pushRoute(.auth);
                  cubit.refreshUser();
                },
              ),
              AuthenticatedUser(:final email) => ProfileHeader(email: email, onAction: cubit.signOut),
            },
            const VTGap.l(),
            ProfileMenuTile(
              icon: Icons.flag_outlined,
              accent: VTColors.macroProtein,
              title: l10n.macroGoalsTitle,
              subtitle: l10n.profileMacroGoalsSubtitle,
              onTap: () => context.pushRoute(.macroGoals),
            ),
            const VTGap.m(),
            ProfileMenuTile(
              icon: Icons.settings_outlined,
              accent: VTColors.macroFat,
              title: l10n.settingsTitle,
              subtitle: l10n.profileSettingsSubtitle,
              onTap: () => context.pushRoute(.settings),
            ),
          ],
        ),
      ),
    );
  }
}
