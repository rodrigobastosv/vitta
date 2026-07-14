import 'package:flutter/material.dart';
import 'package:vitta/app/core/error/error_dialog_extensions.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_cubit.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_presentation_event.dart';
import 'package:vitta/app/presentation/pages/recipe_form/recipe_form_state.dart';
import 'package:vitta/app/presentation/pages/recipe_form/widgets/recipe_form_body.dart';

class RecipeFormPage extends StatelessWidget {
  const RecipeFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<RecipeFormCubit, RecipeFormState, RecipeFormPresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case RecipeFormShowLoading():
            context.showLoading();
          case RecipeFormHideLoading():
            context.hideLoading();
          case RecipeFormIncomplete():
            context.showErrorDialog(message: l10n.dietRecipeIncomplete);
          case RecipeFormError(:final message):
            context.showErrorDialog(message: message);
          case RecipeCreated():
            Navigator.of(context).pop(true);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.dietCreateRecipeTitle)),
        body: RecipeFormBody(state: state),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(VTSpacing.m),
          child: VTPrimaryButton(label: l10n.dietRecipeSaveAction, onPressed: cubit.submit),
        ),
      ),
    );
  }
}
