import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/cubit/premium_cubit.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_extra.dart';
import 'package:vitta/app/presentation/pages/premium/paywall_extra.dart';
import 'package:vitta/app/presentation/pages/premium/premium_state.dart';

// The lock is UX only - it turns a paid tap into an explanation instead of a
// failure. The Edge Function is what actually refuses an unentitled scan.
class MealScanAction extends StatelessWidget {
  const MealScanAction({required this.date, required this.onLogged, super.key});

  final DateTime date;
  final VoidCallback onLogged;

  @override
  Widget build(BuildContext context) => BlocBuilder<PremiumCubit, PremiumState>(
    builder: (context, state) => IconButton(
      icon: state.isPremium
          ? const Icon(Icons.photo_camera_outlined)
          : const Badge(
              backgroundColor: VTColors.premium,
              smallSize: 8,
              child: Icon(Icons.photo_camera_outlined),
            ),
      tooltip: context.l10n.mealScanTitle,
      onPressed: () => state.isPremium ? _scan(context) : _openPaywall(context),
    ),
  );

  Future<void> _scan(BuildContext context) async {
    final hasLogged = await context.pushRoute<bool>(.mealScan, extra: MealScanExtra(loggedDate: date));
    if (hasLogged ?? false) {
      onLogged();
    }
  }

  Future<void> _openPaywall(BuildContext context) =>
      context.pushRoute(.premium, extra: const PaywallExtra(highlightedFeature: .mealScan));
}
