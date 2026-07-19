import 'package:flutter/material.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_image_source_sheet.dart';
import 'package:vitta/app/design_system/components/general/vt_photo_header.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_cubit.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_presentation_event.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_state.dart';
import 'package:vitta/app/presentation/pages/meal_scan/widgets/meal_scan_type_selector.dart';
import 'package:vitta/app/presentation/pages/meal_scan/widgets/scanned_meal_item_card.dart';

class MealScanPage extends StatelessWidget {
  const MealScanPage({required this.loggedDate, super.key});

  final DateTime loggedDate;

  static const double _headerHeight = 260;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<MealScanCubit, MealScanState, MealScanPresentationEvent>(
      cubitParam: loggedDate,
      onPresentation: (context, event) {
        switch (event) {
          case MealScanShowLoading():
            context.showLoading();
          case MealScanHideLoading():
            context.hideLoading();
          case MealScanFoundNothing():
            context.showWarningToast(message: l10n.mealScanNoData, title: l10n.mealScanNoDataTitle);
          case MealScanIncomplete():
            context.showWarningToast(message: l10n.mealScanIncomplete);
          case MealScanError(:final message):
            context.showErrorToast(message: message);
          case MealScanLogged():
            Navigator.of(context).pop(true);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverAppBar(
                expandedHeight: _headerHeight,
                pinned: true,
                stretch: true,
                backgroundColor: context.colorScheme.surface,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
                  background: VTPhotoHeader(imageBytes: state.imageBytes, onTap: () => _scan(context, cubit)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(VTSpacing.m),
                  child: _body(context, cubit, state),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: state.entries.isEmpty
            ? null
            : Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
                child: SafeArea(
                  minimum: const EdgeInsets.all(VTSpacing.m),
                  child: VTPrimaryButton(
                    label: l10n.mealScanLogAction,
                    onPressed: state.canLog ? cubit.logMeal : null,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _body(BuildContext context, MealScanCubit cubit, MealScanState state) {
    final l10n = context.l10n;
    if (!state.hasScanned) {
      return Padding(
        padding: const EdgeInsets.only(top: VTSpacing.xl),
        child: Column(
          children: [
            VTEmptyState(icon: Icons.center_focus_strong_outlined, title: l10n.mealScanIntroTitle, message: l10n.mealScanIntroMessage),
            const VTGap.m(),
            VTPrimaryButton(label: l10n.mealScanTakePhotoAction, icon: Icons.photo_camera_outlined, onPressed: () => _scan(context, cubit)),
          ],
        ),
      );
    }
    if (state.entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: VTSpacing.xl),
        child: Column(
          children: [
            VTEmptyState(icon: Icons.no_food_outlined, title: l10n.mealScanNoDataTitle, message: l10n.mealScanNoData),
            const VTGap.m(),
            VTPrimaryButton(label: l10n.mealScanRetakeAction, icon: Icons.photo_camera_outlined, onPressed: () => _scan(context, cubit)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(l10n.mealScanItemsTitle, style: VTTextStyles.title(context)),
        const VTGap.xs(),
        Text(l10n.mealScanItemsSubtitle, style: VTTextStyles.caption(context)),
        const VTGap.m(),
        for (final (index, entry) in state.entries.indexed) ...[
          VTAppearEffect(
            delay: Duration(milliseconds: index * 60),
            child: ScannedMealItemCard(
              entry: entry,
              onGramsChanged: (text) => cubit.gramsChanged(index: index, text: text),
              onToggle: () => cubit.toggleIncluded(index: index),
            ),
          ),
          const VTGap.s(),
        ],
        const VTGap.m(),
        MealScanTypeSelector(selected: state.mealType, onSelected: cubit.mealTypeChanged),
      ],
    );
  }

  Future<void> _scan(BuildContext context, MealScanCubit cubit) async {
    final source = await showImageSourceSheet(context: context);
    if (source == null) {
      return;
    }
    await cubit.scanMeal(source: source);
  }
}
