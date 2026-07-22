import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/cards/vt_card.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_profile_avatar.dart';
import 'package:vitta/app/design_system/components/general/vt_refreshable.dart';
import 'package:vitta/app/design_system/components/tiles/vt_feature_tile.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/presentation/general/home_feature_labels.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/home/home_cubit.dart';
import 'package:vitta/app/presentation/pages/home/home_presentation_event.dart';
import 'package:vitta/app/presentation/pages/home/home_state.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_feature_row.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_feature_tile.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_greeting.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_hero.dart';
import 'package:vitta/app/presentation/pages/home/widgets/home_skeleton.dart';

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
      builder: (context, cubit, state) {
        final supporting = state.layout.supporting;
        final tiles = state.layout.tiles;
        Future<void> open(HomeFeature feature) async {
          await context.pushRoute(feature.route);
          await cubit.refresh();
        }

        return Scaffold(
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
              if (state.layout.hero case final hero?) ...[
                HomeHero(feature: hero, state: state, unitSystem: cubit.unitSystem, sleepGoalHours: cubit.sleepGoalHours, onOpen: open),
                const VTGap.l(),
              ],
              if (supporting.isNotEmpty) ...[
                Text(l10n.homeAlsoTodayTitle, style: VTTextStyles.overline(context)),
                const VTGap.s(),
                VTCard(
                  padding: const EdgeInsets.symmetric(vertical: VTSpacing.xs),
                  child: Column(
                    children: [
                      for (final feature in supporting) HomeFeatureRow(feature: feature, state: state, unitSystem: cubit.unitSystem, onOpen: open),
                    ],
                  ),
                ),
                const VTGap.l(),
              ],
              Text(l10n.homeTrackTitle, style: VTTextStyles.overline(context)),
              const VTGap.s(),
              for (final pair in _pairs(tiles)) ...[
                Row(
                  children: [
                    Expanded(child: HomeFeatureTile(feature: pair.first, state: state, unitSystem: cubit.unitSystem, onOpen: open)),
                    const VTGap.m(),
                    switch (pair.second) {
                      final second? => Expanded(child: HomeFeatureTile(feature: second, state: state, unitSystem: cubit.unitSystem, onOpen: open)),
                      null => const Spacer(),
                    },
                  ],
                ),
                const VTGap.m(),
              ],
              VTFeatureTile(
                icon: Icons.photo_camera_outlined,
                accent: VTColors.coral,
                title: l10n.progressPhotosFeatureTitle,
                subtitle: l10n.progressPhotosFeatureSubtitle,
                onTap: () => context.pushRoute(.progressPhotos),
              ),
            ],
          ),
        );
      },
    );
  }

  List<({HomeFeature first, HomeFeature? second})> _pairs(List<HomeFeature> features) => [
    for (var index = 0; index < features.length; index += 2)
      (first: features[index], second: index + 1 < features.length ? features[index + 1] : null),
  ];
}
