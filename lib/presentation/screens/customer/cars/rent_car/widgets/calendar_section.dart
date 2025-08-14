import 'package:flutter/material.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';

enum UnavailablePosition {
  start,
  middle,
  end,
  single,
}

class CalendarSection extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final void Function(DateTime) onDateChanged;
  final bool Function(DateTime) isDateUnavailable;

  const CalendarSection({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
    required this.isDateUnavailable,
  }) : super(key: key);

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  late CleanCalendarController calendarController;

  @override
  void initState() {
    super.initState();
    calendarController = CleanCalendarController(
      minDate: widget.firstDate,
      maxDate: widget.lastDate,
      onDayTapped: (date) {
        // Disable date selection - calendar is read-only
      },
      weekdayStart: DateTime.monday,
      initialFocusDate: widget.initialDate,
      rangeMode: false, // Single date selection
    );
  }

  @override
  void dispose() {
    calendarController.dispose();
    super.dispose();
  }

  UnavailablePosition _getUnavailablePosition(DateTime date) {
    final previousDay = date.subtract(const Duration(days: 1));
    final nextDay = date.add(const Duration(days: 1));
    
    final isPreviousUnavailable = widget.isDateUnavailable(previousDay);
    final isNextUnavailable = widget.isDateUnavailable(nextDay);
    
    if (!isPreviousUnavailable && !isNextUnavailable) {
      return UnavailablePosition.single;
    } else if (!isPreviousUnavailable && isNextUnavailable) {
      return UnavailablePosition.start;
    } else if (isPreviousUnavailable && !isNextUnavailable) {
      return UnavailablePosition.end;
    } else {
      return UnavailablePosition.middle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern header
        Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Check Availability',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Legend
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                border: Border.all(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Unavailable',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Calendar
        Container(
          height: 400, // Fixed height for scrollable calendar
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ScrollableCleanCalendar(
              calendarController: calendarController,
              layout: Layout.BEAUTY,
              calendarCrossAxisSpacing: 4,
              calendarMainAxisSpacing: 4,
              padding: const EdgeInsets.all(16),
              monthTextStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              weekdayTextStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              dayTextStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              daySelectedBackgroundColor: colorScheme.primary,
              dayBackgroundColor: colorScheme.surface,
              dayDisableBackgroundColor: colorScheme.surface.withOpacity(0.4),
              dayDisableColor: Colors.red,
              dayRadius: 8,
              dayBuilder: (context, values) {
                final date = values.day;
                final normalizedDate = DateTime(date.year, date.month, date.day);
                final normalizedToday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                final isToday = normalizedDate.isAtSameMomentAs(normalizedToday);
                final isUnavailable = widget.isDateUnavailable(date);
                final isBeforeToday = normalizedDate.isBefore(normalizedToday);
                final isDisabled = isUnavailable || isBeforeToday;
                
                // Determine position in unavailable range
                UnavailablePosition? unavailablePosition;
                if (isUnavailable) {
                  unavailablePosition = _getUnavailablePosition(normalizedDate);
                }
                
                Color backgroundColor;
                if (isUnavailable && unavailablePosition != null) {
                  switch (unavailablePosition) {
                    case UnavailablePosition.start:
                    case UnavailablePosition.end:
                    case UnavailablePosition.single:
                      backgroundColor = const Color(0xFFE53E3E); // Dark red
                      break;
                    case UnavailablePosition.middle:
                      backgroundColor = const Color(0xFFE53E3E).withOpacity(0.3); // Light red
                      break;
                  }
                } else if (isBeforeToday) {
                  backgroundColor = colorScheme.surface.withOpacity(0.3);
                } else {
                  backgroundColor = colorScheme.surface;
                }
                
                return Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isUnavailable && unavailablePosition != null
                                ? (unavailablePosition == UnavailablePosition.middle
                                    ? const Color(0xFFE53E3E) // Dark red text on light background
                                    : Colors.white) // White text on dark red background
                                : isBeforeToday
                                    ? colorScheme.onSurface.withOpacity(0.4)
                                    : isToday
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                        fontWeight: isToday
                            ? FontWeight.w600
                            : isUnavailable
                                ? FontWeight.w600 // Bold for better contrast on colored backgrounds
                                : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
