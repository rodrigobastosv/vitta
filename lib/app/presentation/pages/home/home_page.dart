import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_profile_avatar.dart';
import 'package:vitta/app/design_system/components/tiles/vt_feature_tile.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
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
              CircleAvatar(
                radius: 44,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.eco_outlined, size: 42, color: colorScheme.onPrimaryContainer),
              ),
              const VTGap.m(),
              Text(l10n.appTitle, style: VTTextStyles.display(context).copyWith(fontSize: 54, letterSpacing: -2)),
              const VTGap.xs(),
              Text(l10n.homeTagline, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant)),
              const VTGap.xl(),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: VTSpacing.m,
                crossAxisSpacing: VTSpacing.m,
                childAspectRatio: 0.82,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
