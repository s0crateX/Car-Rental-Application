import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 8.0),
              child: Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Unavailable dates', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            TableCalendar(
              firstDay: firstDate,
              lastDay: lastDate,
              focusedDay: initialDate,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: false,
              ),
              calendarFormat: CalendarFormat.month,
              availableGestures: AvailableGestures.horizontalSwipe,
              selectedDayPredicate: (day) => false, // Selection handled outside
              enabledDayPredicate: (day) {
                final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                if (day.isBefore(today)) return false;
                return !isDateUnavailable(day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isDateUnavailable(selectedDay) && !selectedDay.isBefore(DateTime.now())) {
                  onDateChanged(selectedDay);
                }
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final isUnavailable = isDateUnavailable(day);
                  final today = DateTime.now();
                  final isPast = day.isBefore(DateTime(today.year, today.month, today.day));
                  if (isUnavailable && !isPast) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Container(
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        width: 36,
        height: 36,
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 18,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade700,
                  blurRadius: 1,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 1),
                )
              ],
            ),
          ),
        ],
      ),
    ],
  );
}
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
