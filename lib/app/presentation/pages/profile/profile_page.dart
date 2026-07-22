import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/cubit/premium_cubit.dart';
import 'package:vitta/app/cubit/premium_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';
import 'package:vitta/app/presentation/pages/profile/widgets/delete_account_dialog.dart';
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
          case AuthProfileUpdated():
            break;
          case AuthAccountDeleted():
            context.showToast(title: l10n.profileAccountDeleted, message: l10n.profileAccountDeletedMessage);
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
                  await context.pushRoute(.signUp);
                  cubit.refreshUser();
                },
              ),
              final AuthenticatedUser user => ProfileHeader(
                user: user,
                onAction: cubit.signOut,
                onEdit: () async {
                  await context.pushRoute(.editProfile);
                  cubit.refreshUser();
                },
              ),
            },
            const VTGap.l(),
            BlocBuilder<PremiumCubit, PremiumState>(
              builder: (context, premiumState) => ProfileMenuTile(
                icon: Icons.workspace_premium_outlined,
                accent: VTColors.premium,
                title: l10n.profilePremiumTitle,
                subtitle: premiumState.isPremium ? l10n.profilePremiumSubtitleActive : l10n.profilePremiumSubtitleFree,
                onTap: () => context.pushRoute(.paywall),
              ),
            ),
            const VTGap.m(),
            ProfileMenuTile(
              icon: Icons.flag_outlined,
              accent: VTColors.macroProtein,
              title: l10n.objectiveTitle,
              subtitle: l10n.profileObjectiveSubtitle,
              onTap: () => context.pushRoute(.objective),
            ),
            const VTGap.m(),
            ProfileMenuTile(
              icon: Icons.settings_outlined,
              accent: VTColors.macroFat,
              title: l10n.settingsTitle,
              subtitle: l10n.profileSettingsSubtitle,
              onTap: () => context.pushRoute(.settings),
            ),
            if (state.user is AuthenticatedUser) ...[
              const VTGap.m(),
              ProfileMenuTile(
                icon: Icons.delete_forever_outlined,
                accent: context.colorScheme.error,
                title: l10n.profileDeleteAccountTitle,
                subtitle: l10n.profileDeleteAccountSubtitle,
                onTap: () => _confirmDeleteAccount(context, cubit),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context, AuthCubit cubit) async {
    final confirmed = await showDeleteAccountConfirmation(context: context);
    if (confirmed) {
      await cubit.deleteAccount();
    }
  }
}
