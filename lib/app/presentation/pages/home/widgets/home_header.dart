import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.user, required this.greeting, required this.appTitle, required this.tagline, super.key});

  final User user;
  final String greeting;
  final String appTitle;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    if (user.displayNameOrEmpty case final name when name.isNotEmpty) {
      return Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.eco_outlined, size: 28, color: colorScheme.onPrimaryContainer),
          ),
          const VTGap.m(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(greeting, style: VTTextStyles.caption(context)),
                Text(name, style: VTTextStyles.headline(context), maxLines: 1, overflow: .ellipsis),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: .start,
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.eco_outlined, size: 42, color: colorScheme.onPrimaryContainer),
        ),
        const VTGap.m(),
        Text(appTitle, style: VTTextStyles.display(context).copyWith(fontSize: 54, letterSpacing: -2)),
        const VTGap.xs(),
        Text(tagline, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
