import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.workoutFeatureTitle)),
      body: VTEmptyState(icon: Icons.fitness_center_outlined, title: l10n.comingSoonTitle, message: l10n.workoutComingSoonMessage),
    );
  }
}
