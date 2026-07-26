import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_scanning_overlay.dart';
import 'package:vitta/app/design_system/components/general/vt_skeleton.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/general/meal_type_selector.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_cubit.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_presentation_event.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_state.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/widgets/macro_gap_card.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/widgets/suggested_meal_card.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/widgets/suggested_meal_item_card.dart';
import 'package:vitta/app/presentation/pages/paywall/paywall_extra.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class MealSuggestionPage extends StatelessWidget {
  const MealSuggestionPage({required this.loggedDate, super.key});

  final DateTime loggedDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<MealSuggestionCubit, MealSuggestionState, MealSuggestionPresentationEvent>(
      cubitParam: loggedDate,
      onPresentation: (context, event) {
        switch (event) {
          case MealSuggestionShowLoading():
            context.showLoading();
          case MealSuggestionThinking():
            context.showLoading(
              widget: VTScanningOverlay(
                icon: Icons.auto_awesome_outlined,
                captions: [
                  l10n.mealSuggestionThinkingCaptionReading,
                  l10n.mealSuggestionThinkingCaptionBalancing,
                  l10n.mealSuggestionThinkingCaptionPlating,
                ],
              ),
            );
          case MealSuggestionHideLoading():
            context.hideLoading();
          case MealSuggestionFoundNothing():
            context.showWarningToast(message: l10n.mealSuggestionNoData, title: l10n.mealSuggestionNoDataTitle);
          case MealSuggestionIncomplete():
            context.showWarningToast(message: l10n.mealSuggestionIncomplete);
          case MealSuggestionPremiumRequired():
            context.showWarningToast(message: l10n.premiumRequiredMessage, title: l10n.premiumRequiredTitle);
            unawaited(context.pushRoute(.paywall, extra: const PaywallExtra(highlightedFeature: .mealSuggestion)));
          case MealSuggestionError(:final message):
            context.showErrorToast(message: message);
          case MealSuggestionLogged():
            Navigator.of(context).pop(true);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.mealSuggestionTitle)),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(VTSpacing.m),
            child: state.isLoaded ? _body(context, cubit, state, l10n) : _skeleton(),
          ),
        ),
        // The one primary action lives here in every state, which is also why the
        // found-nothing empty state carries no CTA of its own: two buttons asking
        // for the same retry is the FAB-and-empty-state duplication again.
        bottomNavigationBar: state.isLoaded
            ? Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
                child: SafeArea(
                  minimum: const EdgeInsets.all(VTSpacing.m),
                  child: state.meals.isEmpty
                      ? VTPrimaryButton(
                          label: state.hasRequested ? l10n.mealSuggestionRetryAction : l10n.mealSuggestionRequestAction,
                          icon: Icons.auto_awesome_outlined,
                          onPressed: cubit.suggestMeals,
                        )
                      : VTPrimaryButton(label: l10n.mealSuggestionLogAction, onPressed: state.canLog ? cubit.logMeal : null),
                ),
              )
            : null,
      ),
    );
  }

  Widget _skeleton() => const Column(
    crossAxisAlignment: .stretch,
    children: [VTSkeleton.card(height: 150), VTGap.m(), VTSkeleton(height: 24, width: 140), VTGap.m(), VTSkeleton.card(height: 60)],
  );

  Widget _body(BuildContext context, MealSuggestionCubit cubit, MealSuggestionState state, AppLocalizations l10n) => Column(
    crossAxisAlignment: .stretch,
    children: [
      VTAppearEffect(child: MacroGapCard(gap: state.gap)),
      const VTGap.l(),
      VTAppearEffect(
        index: 1,
        child: MealTypeSelector(title: l10n.mealSuggestionMealTypeTitle, selected: state.mealType, onSelected: cubit.mealTypeChanged),
      ),
      const VTGap.l(),
      if (!state.hasRequested)
        VTAppearEffect(
          index: 2,
          child: Text(l10n.mealSuggestionIntroMessage, style: VTTextStyles.caption(context).copyWith(color: context.colorScheme.onSurfaceVariant)),
        )
      else if (state.meals.isEmpty)
        VTEmptyState(icon: Icons.no_meals_outlined, title: l10n.mealSuggestionNoDataTitle, message: l10n.mealSuggestionNoData)
      else
        ..._suggestions(context, cubit, state, l10n),
    ],
  );

  List<Widget> _suggestions(BuildContext context, MealSuggestionCubit cubit, MealSuggestionState state, AppLocalizations l10n) => [
    Text(l10n.mealSuggestionPickTitle, style: VTTextStyles.bodyStrong(context)),
    const VTGap.s(),
    for (final (index, meal) in state.meals.indexed) ...[
      VTAppearEffect(
        index: index + 1,
        child: SuggestedMealCard(meal: meal, isSelected: index == state.selectedIndex, onTap: () => cubit.selectMeal(index)),
      ),
      const VTGap.s(),
    ],
    const VTGap.m(),
    Text(l10n.mealSuggestionItemsTitle, style: VTTextStyles.bodyStrong(context)),
    const VTGap.xs(),
    Text(l10n.mealSuggestionItemsSubtitle, style: VTTextStyles.caption(context).copyWith(color: context.colorScheme.onSurfaceVariant)),
    const VTGap.m(),
    for (final (index, entry) in state.selectedEntries.indexed) ...[
      SuggestedMealItemCard(
        // Keyed by the option it belongs to as well as its position: the rows
        // are rebuilt when another option is picked, and without this the
        // amount fields would keep the previous option's text.
        key: ValueKey('${state.selectedIndex}-$index'),
        entry: entry,
        onGramsChanged: (text) => cubit.gramsChanged(index: index, text: text),
        onToggle: () => cubit.toggleIncluded(index: index),
      ),
      const VTGap.s(),
    ],
  ];
}
