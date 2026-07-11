import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.workoutFeatureTitle)),
      body: VTEmptyState(icon: Icons.fitness_center_outlined, title: l10n.comingSoonTitle, message: l10n.workoutComingSoonMessage),
    );
  }
}
