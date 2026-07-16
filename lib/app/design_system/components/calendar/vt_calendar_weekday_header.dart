import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/calendar/vt_calendar_week_badge.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class VTCalendarWeekdayHeader extends StatelessWidget {
  const VTCalendarWeekdayHeader({this.weekColumnLabel, super.key});

  final String? weekColumnLabel;

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
        if (weekColumnLabel case final weekColumnLabel?)
          SizedBox(
            width: VTCalendarWeekBadge.width,
            child: Center(child: Text(weekColumnLabel, style: VTTextStyles.overline(context))),
          ),
      ],
    );
  }
}
