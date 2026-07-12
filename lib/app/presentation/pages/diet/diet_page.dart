import 'package:flutter/material.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_error_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_presentation_event.dart';
import 'package:vitta/app/presentation/pages/diet/diet_state.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/food_log_tile.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/macro_summary_card.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class DietPage extends StatelessWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context) => VTPage<DietCubit, DietState, DietPresentationEvent>(
    builder: (context, cubit, state) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(l10n.dietFeatureTitle)),
        body: switch (state) {
          DietError(:final message) => VTErrorState(message: message, retryLabel: l10n.retry, onRetry: cubit.loadToday),
          DietLoaded(:final dailyMacros) => RefreshIndicator(
            onRefresh: cubit.loadToday,
            child: dailyMacros.entries.isEmpty
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(VTSpacing.m),
                        child: MacroSummaryCard(dailyMacros: dailyMacros),
                      ),
                      VTEmptyState(icon: Icons.restaurant_outlined, title: l10n.dietEmptyTitle, message: l10n.dietEmptyMessage),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(VTSpacing.m),
                    children: [
                      MacroSummaryCard(dailyMacros: dailyMacros),
                      const VTGap.l(),
                      for (final entry in dailyMacros.entries) ...[
                        FoodLogTile(entry: entry, onDelete: () => cubit.deleteLog(logId: entry.log.id)),
                        const VTGap.s(),
                      ],
                    ],
                  ),
          ),
        },
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await context.pushRoute(.foodSearch);
            await cubit.loadToday();
          },
          child: const Icon(Icons.add),
        ),
      );
    },
  );
}
