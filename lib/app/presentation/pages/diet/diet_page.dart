import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class DietPage extends StatelessWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dietFeatureTitle)),
      body: VTEmptyState(icon: Icons.restaurant_outlined, title: l10n.comingSoonTitle, message: l10n.dietComingSoonMessage),
    );
  }
}
