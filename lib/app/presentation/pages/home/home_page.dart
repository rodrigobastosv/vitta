import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_profile_avatar.dart';
import 'package:vitta/app/design_system/components/general/vt_refreshable.dart';
import 'package:vitta/app/design_system/components/tiles/vt_feature_tile.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/home/home_cubit.dart';
import 'package:vitta/app/presentation/pages/home/home_presentation_event.dart';
import 'package:vitta/app/presentation/pages/home/home_state.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_greeting.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_skeleton.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_supporting_row.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_today_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<HomeCubit, HomeState, HomePresentationEvent>(
      onPresentation: (context, event) => switch (event) {
        HomeShowLoading() => context.showLoading(),
        HomeHideLoading() => context.hideLoading(),
        HomeError(:final message) => context.showErrorToast(message: message, onRetry: context.read<HomeCubit>().refresh),
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(
          title: HomeGreeting(user: state.user, mealCount: state.loggedMealCount),
          titleSpacing: VTSpacing.m,
          actions: [
            IconButton(
              tooltip: l10n.trendsFeatureTooltip,
              icon: const Icon(Icons.insights_outlined),
              onPressed: () => context.pushRoute(.trends),
            ),
            Padding(
              padding: const EdgeInsets.only(right: VTSpacing.s),
              child: Tooltip(
                message: l10n.profileTitle,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () async {
                    await context.pushRoute(.profile);
                    await cubit.refresh();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(VTSpacing.xs),
                    child: VTProfileAvatar(
                      size: 38,
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
        body: VTRefreshable(
          onRefresh: cubit.refresh,
          isLoaded: state.isLoaded,
          skeleton: const HomeSkeleton(),
          children: [
            HomeTodayCard(
              dailyMacros: state.dailyMacros,
              macroGoals: state.macroGoals,
              onTap: () async {
                await context.pushRoute(.diet);
                await cubit.refresh();
              },
            ),
            const VTGap.l(),
            Text(l10n.homeAlsoTodayTitle, style: VTTextStyles.overline(context)),
            const VTGap.s(),
            VTCard(
              padding: const EdgeInsets.symmetric(vertical: VTSpacing.xs),
              child: Column(
                children: [
                  HomeSupportingRow(
                    icon: Icons.water_drop_outlined,
                    accent: VTColors.water,
                    title: l10n.waterFeatureTitle,
                    subtitle: state.waterLeftMl <= 0
                        ? l10n.homeWaterDone
                        : l10n.homeWaterLeft(
                            cubit.unitSystem.millilitersToDisplayVolume(state.waterLeftMl).round().toString(),
                            cubit.unitSystem.volumeUnitLabel,
                          ),
                    value: '${cubit.unitSystem.millilitersToDisplayVolume(state.consumedMl).round()} ${cubit.unitSystem.volumeUnitLabel}',
                    onTap: () async {
                      await context.pushRoute(.water);
                      await cubit.refresh();
                    },
                  ),
                  HomeSupportingRow(
                    icon: Icons.checklist_rounded,
                    accent: VTColors.coral,
                    title: state.nextReminder?.title ?? l10n.reminderFeatureTitle,
                    subtitle: state.nextReminder == null ? l10n.homeNoReminders : l10n.homeNextReminder,
                    value: switch (state.nextReminder?.remindAt) {
                      final remindAt? => context.materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(remindAt)),
                      _ => '',
                    },
                    onTap: () async {
                      await context.pushRoute(.reminders);
                      await cubit.refresh();
                    },
                  ),
                  HomeSupportingRow(
                    icon: Icons.fitness_center_outlined,
                    accent: VTColors.green,
                    title: l10n.workoutFeatureTitle,
                    subtitle: state.hasWorkoutToday ? l10n.homeWorkoutProgress(state.completedExercises, state.totalExercises) : l10n.homeNoWorkout,
                    value: state.hasWorkoutToday ? '${state.completedExercises}/${state.totalExercises}' : '',
                    onTap: () async {
                      await context.pushRoute(.workout);
                      await cubit.refresh();
                    },
                  ),
                ],
              ),
            ),
            const VTGap.l(),
            Text(l10n.homeTrackTitle, style: VTTextStyles.overline(context)),
            const VTGap.s(),
            Row(
              children: [
                Expanded(
                  child: VTFeatureTile(
                    icon: Icons.bedtime_outlined,
                    accent: VTColors.sleep,
                    title: l10n.sleepFeatureTitle,
                    subtitle: switch (state.lastNightHours) {
                      final hours? => l10n.sleepDurationLabel(hours.floor(), ((hours - hours.floor()) * 60).round()),
                      null => l10n.homeNotTrackedYet,
                    },
                    onTap: () async {
                      await context.pushRoute(.sleep);
                      await cubit.refresh();
                    },
                  ),
                ),
                const VTGap.m(),
                Expanded(
                  child: VTFeatureTile(
                    icon: Icons.monitor_weight_outlined,
                    accent: VTColors.success,
                    title: l10n.bodyWeightFeatureTitle,
                    subtitle: switch (state.latestWeightKg) {
                      final weightKg? => '${cubit.unitSystem.kilogramsToDisplayLoad(weightKg).toStringAsFixed(1)} ${cubit.unitSystem.loadUnitLabel}',
                      null => l10n.homeNotTrackedYet,
                    },
                    onTap: () async {
                      await context.pushRoute(.bodyWeight);
                      await cubit.refresh();
                    },
                  ),
                ),
              ],
            ),
            const VTGap.m(),
            VTFeatureTile(
              icon: Icons.photo_camera_outlined,
              accent: VTColors.coral,
              title: l10n.progressPhotosFeatureTitle,
              subtitle: l10n.progressPhotosFeatureSubtitle,
              onTap: () => context.pushRoute(.progressPhotos),
            ),
          ],
        ),
      ),
    );
  }
}
