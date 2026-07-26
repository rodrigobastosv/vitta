import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/cubit/premium_cubit.dart';
import 'package:vitta/app/cubit/premium_state.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/presentation/pages/meal_suggestion/meal_suggestion_extra.dart';
import 'package:vitta/app/presentation/pages/paywall/paywall_extra.dart';

// The lock is UX only - it turns a paid tap into an explanation instead of a
// failure. The Edge Function is what actually refuses an unentitled request.
class MealSuggestionAction extends StatelessWidget {
  const MealSuggestionAction({required this.date, required this.onLogged, super.key});

  final DateTime date;
  final VoidCallback onLogged;

  @override
  Widget build(BuildContext context) => BlocBuilder<PremiumCubit, PremiumState>(
    builder: (context, state) => IconButton(
      icon: state.isPremium
          ? const Icon(Icons.auto_awesome_outlined)
          : const Badge(backgroundColor: VTColors.premium, smallSize: 8, child: Icon(Icons.auto_awesome_outlined)),
      tooltip: context.l10n.mealSuggestionTitle,
      onPressed: () => state.isPremium ? _suggest(context) : _openPaywall(context),
    ),
  );

  Future<void> _suggest(BuildContext context) async {
    final hasLogged = await context.pushRoute<bool>(.mealSuggestion, extra: MealSuggestionExtra(loggedDate: date));
    if (hasLogged ?? false) {
      onLogged();
    }
  }

  Future<void> _openPaywall(BuildContext context) => context.pushRoute(.paywall, extra: const PaywallExtra(highlightedFeature: .mealSuggestion));
}
