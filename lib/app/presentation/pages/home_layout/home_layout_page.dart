import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_drag_handle.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/home_layout/home_layout_cubit.dart';
import 'package:vitta/app/presentation/pages/home_layout/home_layout_presentation_event.dart';
import 'package:vitta/app/presentation/pages/home_layout/home_layout_state.dart';
import 'package:vitta/app/presentation/pages/home_layout/widgets/home_layout_feature_tile.dart';
import 'package:vitta/app/presentation/pages/home_layout/widgets/home_slot_sheet.dart';

class HomeLayoutPage extends StatelessWidget {
  const HomeLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<HomeLayoutCubit, HomeLayoutState, HomeLayoutPresentationEvent>(
      onPresentation: (context, event) => switch (event) {
        HomeLayoutReset() => context.showToast(title: l10n.homeLayoutTitle, message: l10n.homeLayoutResetMessage),
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.homeLayoutTitle),
          actions: [TextButton(onPressed: cubit.resetToDefault, child: Text(l10n.homeLayoutResetAction))],
        ),
        body: Column(
          crossAxisAlignment: .stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(VTSpacing.m, VTSpacing.m, VTSpacing.m, 0),
              child: Text(l10n.homeLayoutMessage, style: VTTextStyles.caption(context)),
            ),
            const VTGap.s(),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(VTSpacing.m, 0, VTSpacing.m, VTSpacing.xxl),
                itemCount: state.layout.order.length,
                buildDefaultDragHandles: false,
                onReorderStart: (_) => VTHaptics.drag(),
                onReorderEnd: (_) => VTHaptics.drag(),
                onReorderItem: (oldIndex, newIndex) => cubit.reorderFeatures(oldIndex: oldIndex, newIndex: newIndex),
                itemBuilder: (context, index) {
                  final feature = state.layout.order[index];
                  return Padding(
                    key: ValueKey(feature.wireValue),
                    padding: const EdgeInsets.only(bottom: VTSpacing.s),
                    child: HomeLayoutFeatureTile(
                      feature: feature,
                      slot: state.layout.slotOf(feature),
                      dragHandle: ReorderableDragStartListener(index: index, child: const VTDragHandle()),
                      onTap: () async {
                        final picked = await showHomeSlotSheet(context, feature: feature, slot: state.layout.slotOf(feature));
                        if (picked != null) {
                          await cubit.changeSlot(feature: feature, slot: picked);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
