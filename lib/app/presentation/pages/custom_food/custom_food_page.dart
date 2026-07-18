import 'package:flutter/material.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_image_source_sheet.dart';
import 'package:vitta/app/design_system/components/general/vt_photo_header.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_cubit.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_presentation_event.dart';
import 'package:vitta/app/presentation/pages/custom_food/custom_food_state.dart';
import 'package:vitta/app/presentation/pages/custom_food/widgets/custom_food_form.dart';

class CustomFoodPage extends StatelessWidget {
  const CustomFoodPage({super.key});

  static const double _headerHeight = 260;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<CustomFoodCubit, CustomFoodState, CustomFoodPresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case CustomFoodShowLoading():
            context.showLoading();
          case CustomFoodHideLoading():
            context.hideLoading();
          case CustomFoodIncomplete():
            context.showWarningToast(message: l10n.dietInvalidCustomFood);
          case CustomFoodScanFoundNothing():
            context.showWarningToast(message: l10n.dietNutritionScanNoData, title: l10n.dietNutritionScanNoDataTitle);
          case CustomFoodError(:final message):
            context.showErrorToast(message: message);
          case CustomFoodReady(:final food):
            Navigator.of(context).pop(food);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              expandedHeight: _headerHeight,
              pinned: true,
              stretch: true,
              backgroundColor: context.colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
                background: VTPhotoHeader(imageBytes: state.imageBytes, onTap: () => _pickPhoto(context, cubit)),
              ),
            ),
            SliverToBoxAdapter(child: CustomFoodForm(state: state)),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(VTSpacing.m),
          child: VTPrimaryButton(label: l10n.saveAction, onPressed: cubit.submit),
        ),
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context, CustomFoodCubit cubit) async {
    final source = await showImageSourceSheet(context: context);
    if (source == null) {
      return;
    }
    await cubit.pickPhoto(source: source);
  }
}
