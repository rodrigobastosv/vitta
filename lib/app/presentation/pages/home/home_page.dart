import 'package:flutter/material.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/tiles/vt_feature_tile.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => VTPage<AuthCubit, AuthState, AuthPresentationEvent>(
    builder: (context, cubit, state) {
      final colorScheme = Theme.of(context).colorScheme;
      final l10n = AppLocalizations.of(context);
      final status = (state as AuthLoaded).status;
      final email = status.email;
      return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.primaryContainer,
                child: !status.isAnonymous && email != null && email.isNotEmpty
                    ? Text(
                        email[0].toUpperCase(),
                        style: VTTextStyles.body(context).copyWith(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                      )
                    : Icon(Icons.person_outline, size: 18, color: colorScheme.onPrimaryContainer),
              ),
              tooltip: l10n.profileTitle,
              onPressed: () async {
                await context.pushRoute(.profile);
                cubit.refreshStatus();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m, vertical: VTSpacing.s),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.eco_outlined, size: 32, color: colorScheme.onPrimaryContainer),
              ),
              const VTGap.m(),
              Text(l10n.appTitle, style: VTTextStyles.display(context)),
              const VTGap.xs(),
              Text(l10n.homeTagline, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant)),
              const VTGap.xl(),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: VTSpacing.m,
                crossAxisSpacing: VTSpacing.m,
                childAspectRatio: 1.1,
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
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
