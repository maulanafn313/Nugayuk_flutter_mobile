// lib/user/calendar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // For date formatting if needed for display
import 'schedule_provider.dart';
import '../models/schedule.dart'; // Your Schedule model
import 'detail_schedule.dart'; // If you want to navigate to details
import 'dashboardpage.dart'; // Assuming you have a DashboardPage to navigate back to

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Schedule>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Load schedules when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scheduleProvider = Provider.of<ScheduleProvider>(
        context,
        listen: false,
      );
      scheduleProvider.loadSchedules(context).then((_) {
        _groupSchedulesByDate(scheduleProvider.schedules);
      });
    });
  }

  void _groupSchedulesByDate(List<Schedule> schedules) {
    Map<DateTime, List<Schedule>> newEvents = {};
    for (var schedule in schedules) {
      // Normalize to UTC to ensure date equality works as expected by table_calendar
      DateTime dateKey = DateTime.utc(
        schedule.startSchedule.year,
        schedule.startSchedule.month,
        schedule.startSchedule.day,
      );
      if (newEvents[dateKey] == null) {
        newEvents[dateKey] = [];
      }
      newEvents[dateKey]!.add(schedule);
    }
    if (mounted) {
      setState(() {
        _events = newEvents;
      });
    }
  }

  List<Schedule> _getEventsForDay(DateTime day) {
    // Normalize the input day to UTC for map lookup
    DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay; // update `_focusedDay` here as well
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in ScheduleProvider to regroup events if schedules change
    // This can be useful if schedules are added/updated while the calendar is open
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    if (scheduleProvider.schedules.isNotEmpty && _events.isEmpty) {
      // Initial grouping if not done
      _groupSchedulesByDate(scheduleProvider.schedules);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFFFFFFFF), // Ensure back button is visible
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Colors.white, // Keep original style if preferred
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(
          0xFF1E3A8A,
        ), // Keep original style [cite: 721]
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Ensure back button is visible
      ),
      body: Column(
        children: [
          TableCalendar<Schedule>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color:
                    Theme.of(
                      context,
                    ).primaryColorDark, // Or Colors.deepOrange [cite: 724]
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.blue[700], // Or Colors.blue [cite: 724]
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false, // [cite: 725]
              titleCentered: true, // [cite: 725]
            ),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child:
                _selectedDay == null || _getEventsForDay(_selectedDay!).isEmpty
                    ? const Center(
                      child: Text(
                        'No schedules for this day.', // [cite: 728] (modified)
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _getEventsForDay(_selectedDay!).length,
                      itemBuilder: (context, index) {
                        final schedule = _getEventsForDay(_selectedDay!)[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.event_note,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text(schedule.scheduleName),
                            subtitle: Text(
                              'Time: ${DateFormat('HH:mm').format(schedule.startSchedule)}'
                              '\nCategory: ${schedule.categoryName}',
                            ),
                            isThreeLine: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DetailSchedulePage(
                                        title: schedule.scheduleName,
                                        category: schedule.categoryName,
                                        priority: schedule.priority,
                                        description:
                                            schedule.description ??
                                            'No Description',
                                        startDate:
                                            schedule.startSchedule
                                                .toIso8601String(),
                                        dueDate:
                                            schedule.dueSchedule
                                                .toIso8601String(),
                                        reminder:
                                            schedule.beforeDueSchedule
                                                .toIso8601String(),
                                        status: schedule.status,
                                        url: schedule.url ?? '',
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
