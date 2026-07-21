import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({required this.user, required this.mealCount, super.key});

  final User user;
  final int mealCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final name = user.displayNameOrEmpty;
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        Text(
          l10n.homeMealsLogged(mealCount),
          style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
          maxLines: 1,
          overflow: .ellipsis,
        ),
        Text(name.isEmpty ? l10n.appTitle : name, style: VTTextStyles.title(context), maxLines: 1, overflow: .ellipsis),
      ],
    );
  }
}
