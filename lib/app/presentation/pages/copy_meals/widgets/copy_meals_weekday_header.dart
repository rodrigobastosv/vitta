import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class CopyMealsWeekdayHeader extends StatelessWidget {
  const CopyMealsWeekdayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final materialLocalizations = context.materialLocalizations;
    return Row(
      children: [
        for (var index = 0; index < DateTime.daysPerWeek; index++)
          Expanded(
            child: Center(
              child: Text(
                materialLocalizations.narrowWeekdays[(materialLocalizations.firstDayOfWeekIndex + index) % DateTime.daysPerWeek],
                style: VTTextStyles.overline(context),
              ),
            ),
          ),
      ],
    );
  }
}
