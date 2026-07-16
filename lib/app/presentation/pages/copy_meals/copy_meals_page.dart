import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_cubit.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_presentation_event.dart';
import 'package:vitta/app/presentation/pages/copy_meals/copy_meals_state.dart';
import 'package:vitta/app/presentation/pages/copy_meals/widgets/copy_meals_calendar_card.dart';
import 'package:vitta/app/presentation/pages/copy_meals/widgets/copy_meals_selection_card.dart';

class CopyMealsPage extends StatelessWidget {
  const CopyMealsPage({required this.targetDate, super.key});

  final DateTime targetDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<CopyMealsCubit, CopyMealsState, CopyMealsPresentationEvent>(
      cubitParam: targetDate,
      onPresentation: (context, event) {
        switch (event) {
          case CopyMealsShowLoading():
            context.showLoading();
          case CopyMealsHideLoading():
            context.hideLoading();
          case CopyMealsError(:final message):
            context.showErrorToast(message: message, onRetry: context.read<CopyMealsCubit>().refresh);
          case MealsCopied(:final mealCount):
            context.showToast(title: l10n.dietMealsCopiedToastTitle, message: l10n.dietMealsCopiedToastMessage(mealCount));
            Navigator.of(context).pop(true);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.dietCopyMealsTitle)),
        body: ListView(
          padding: const EdgeInsets.all(VTSpacing.m),
          children: [
            Text(l10n.dietCopyMealsPrompt, style: VTTextStyles.body(context)),
            const VTGap.m(),
            CopyMealsCalendarCard(cubit: cubit, state: state),
            const VTGap.m(),
            if (state.sourceMeals.isEmpty)
              VTEmptyState(icon: Icons.event_outlined, title: l10n.dietCopyMealsNoSourceTitle, message: l10n.dietCopyMealsNoSourceMessage)
            else
              CopyMealsSelectionCard(meals: state.sourceMeals, selectedMealTypes: state.selectedMealTypes, onToggleMeal: cubit.toggleMeal),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(VTSpacing.m),
          child: VTPrimaryButton(label: l10n.dietCopyMealsAction, onPressed: state.canCopy ? cubit.copy : null),
        ),
      ),
    );
  }
}
