import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/diet/diet_state.dart';

Future<DateTime?> showDietCalendarSheet({required BuildContext context}) => showModalBottomSheet<DateTime>(
  context: context,
  isScrollControlled: true,
  builder: (sheetContext) => BlocProvider.value(value: context.read<DietCubit>(), child: const _DietCalendarSheet()),
);

class _DietCalendarSheet extends StatefulWidget {
  const _DietCalendarSheet();

  @override
  State<_DietCalendarSheet> createState() => _DietCalendarSheetState();
}

class _DietCalendarSheetState extends State<_DietCalendarSheet> {
  late DateTime _displayedMonth = _monthOf(context.read<DietCubit>().state.date);
  bool _isLoading = false;

  static DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  @override
  void initState() {
    super.initState();
    _loadMonth(_displayedMonth);
  }

  Future<void> _loadMonth(DateTime month) async {
    setState(() => _isLoading = true);
    await context.read<DietCubit>().loadLoggedDatesForMonth(month);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _changeMonth(int monthDelta) {
    final month = DateTime(_displayedMonth.year, _displayedMonth.month + monthDelta);
    setState(() => _displayedMonth = month);
    _loadMonth(month);
  }

  @override
  Widget build(BuildContext context) {
    final materialLocalizations = MaterialLocalizations.of(context);
    final isCurrentMonth = _displayedMonth == _monthOf(DateTime.now());

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(VTSpacing.m),
        child: Column(
          mainAxisSize: .min,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeMonth(-1)),
                Text(materialLocalizations.formatMonthYear(_displayedMonth), style: VTTextStyles.title(context)),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: isCurrentMonth ? null : () => _changeMonth(1)),
              ],
            ),
            const VTGap.m(),
            _WeekdayHeader(materialLocalizations: materialLocalizations),
            const VTGap.s(),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: VTSpacing.l),
                child: CircularProgressIndicator(),
              )
            else
              BlocBuilder<DietCubit, DietState>(
                builder: (context, state) => _MonthGrid(
                  month: _displayedMonth,
                  selectedDate: state.date,
                  loggedDates: state.loggedDatesInMonth,
                  firstDayOfWeekIndex: materialLocalizations.firstDayOfWeekIndex,
                  onDaySelected: (day) => Navigator.of(context).pop(day),
                ),
              ),
            const VTGap.m(),
          ],
        ),
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.materialLocalizations});

  final MaterialLocalizations materialLocalizations;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Center(
              child: Text(
                materialLocalizations.narrowWeekdays[(materialLocalizations.firstDayOfWeekIndex + i) % 7],
                style: VTTextStyles.caption(context).copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectedDate,
    required this.loggedDates,
    required this.firstDayOfWeekIndex,
    required this.onDaySelected,
  });

  final DateTime month;
  final DateTime selectedDate;
  final Set<DateTime> loggedDates;
  final int firstDayOfWeekIndex;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekdaySundayIndex = DateTime(month.year, month.month).weekday % 7;
    final leadingBlanks = (firstWeekdaySundayIndex - firstDayOfWeekIndex + 7) % 7;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemCount: leadingBlanks + daysInMonth,
      itemBuilder: (context, index) {
        if (index < leadingBlanks) {
          return const SizedBox.shrink();
        }
        final day = DateTime(month.year, month.month, index - leadingBlanks + 1);
        final isSelected = day == selectedDate;
        final isFuture = day.isAfter(todayOnly);
        final hasLog = loggedDates.contains(day);

        return InkWell(
          onTap: isFuture ? null : () => onDaySelected(day),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isSelected ? colorScheme.primary : Colors.transparent,
                foregroundColor: isSelected
                    ? colorScheme.onPrimary
                    : isFuture
                    ? colorScheme.onSurface.withValues(alpha: 0.3)
                    : colorScheme.onSurface,
                child: Text('${day.day}'),
              ),
              if (hasLog)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                )
              else
                const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }
}
