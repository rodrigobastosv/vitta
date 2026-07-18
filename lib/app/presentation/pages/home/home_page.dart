import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_profile_avatar.dart';
import 'package:vitta/app/design_system/components/tiles/vt_feature_tile.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_header.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 5 || hour >= 18) {
      return l10n.homeGreetingEvening;
    }
    if (hour < 12) {
      return l10n.homeGreetingMorning;
    }
    return l10n.homeGreetingAfternoon;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<AuthCubit, AuthState, AuthPresentationEvent>(
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: VTSpacing.s),
              child: Tooltip(
                message: l10n.profileTitle,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () async {
                    await context.pushRoute(.profile);
                    cubit.refreshUser();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(VTSpacing.xs),
                    child: VTProfileAvatar(
                      size: 40,
                      avatarUrl: switch (state.user) {
                        AuthenticatedUser(:final avatarUrl) => avatarUrl,
                        _ => null,
                      },
                      avatarId: switch (state.user) {
                        AuthenticatedUser(:final avatarId) => avatarId,
                        _ => null,
                      },
                      initial: switch (state.user) {
                        final AuthenticatedUser user => user.initial,
                        _ => null,
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m, vertical: VTSpacing.s),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              HomeHeader(
                user: state.user,
                greeting: _greeting(l10n),
                appTitle: l10n.appTitle,
                tagline: l10n.homeTagline,
              ),
              const VTGap.xl(),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: VTSpacing.m,
                  crossAxisSpacing: VTSpacing.m,
                  mainAxisExtent: 180,
                ),
                children: [
                  VTFeatureTile(
                    icon: Icons.restaurant_outlined,
                    title: l10n.dietFeatureTitle,
                    subtitle: l10n.dietFeatureSubtitle,
                    onTap: () => context.pushRoute(.diet),
                  ),
                  VTFeatureTile(
                    icon: Icons.fitness_center_outlined,
                    title: l10n.workoutFeatureTitle,
                    subtitle: l10n.workoutFeatureSubtitle,
                    onTap: () => context.pushRoute(.workout),
                  ),
                  VTFeatureTile(
                    icon: Icons.water_drop_outlined,
                    title: l10n.waterFeatureTitle,
                    subtitle: l10n.waterFeatureSubtitle,
                    onTap: () => context.pushRoute(.water),
                  ),
                  VTFeatureTile(
                    icon: Icons.bedtime_outlined,
                    title: l10n.sleepFeatureTitle,
                    subtitle: l10n.sleepFeatureSubtitle,
                    onTap: () => context.pushRoute(.sleep),
                  ),
                  VTFeatureTile(
                    icon: Icons.monitor_weight_outlined,
                    title: l10n.bodyWeightFeatureTitle,
                    subtitle: l10n.bodyWeightFeatureSubtitle,
                    onTap: () => context.pushRoute(.bodyWeight),
                  ),
                  VTFeatureTile(
                    icon: Icons.checklist_rounded,
                    title: l10n.reminderFeatureTitle,
                    subtitle: l10n.reminderFeatureSubtitle,
                    onTap: () => context.pushRoute(.reminders),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
