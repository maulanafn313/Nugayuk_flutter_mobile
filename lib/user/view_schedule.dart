// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'schedule_provider.dart';
import 'package:intl/intl.dart';
import 'detail_schedule.dart';
import 'update_schedule.dart';
// import '../models/schedule.dart';

class ViewSchedulePage extends StatefulWidget {
  const ViewSchedulePage({super.key});

  @override
  _ViewSchedulePageState createState() => _ViewSchedulePageState();
}

class _ViewSchedulePageState extends State<ViewSchedulePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().loadSchedules(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Schedule',
          style: TextStyle(
            color: Color(0xFF0A2472),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0A2472)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: RefreshIndicator(
          // Tambahkan RefreshIndicator
          onRefresh: () => scheduleProvider.loadSchedules(context),
          child:
              scheduleProvider.schedules
                      .where((schedule) => schedule.status != 'completed')
                      .isEmpty
                  ? const Center(
                    child: Text(
                      'No schedules available',
                      style: TextStyle(fontSize: 16, color: Color(0xFF0A2472)),
                    ),
                  )
                  : ListView.builder(
                    itemCount:
                        scheduleProvider.schedules
                            .where((schedule) => schedule.status != 'completed')
                            .length,
                    itemBuilder: (context, index) {
                      final schedule =
                          scheduleProvider.schedules
                              .where(
                                (schedule) => schedule.status != 'completed',
                              )
                              .toList()[index];
                      return Card(
                        color: const Color(0xFFB3E0FB), // Warna biru muda
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.title,
                                    color: Color(0xFF0A2472),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      schedule.scheduleName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A2472),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.category,
                                    size: 18,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 6),
                                  Text('Category: ${schedule.categoryName}'),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.flag,
                                    size: 18,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 6),
                                  Text('Priority: ${schedule.priority}'),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info,
                                    size: 18,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 6),
                                  Text('Status: ${schedule.status}'),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Start: ${DateFormat('dd/MM/yyyy HH:mm').format(schedule.startSchedule)}',
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.event,
                                    size: 18,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Due: ${DateFormat('dd/MM/yyyy HH:mm').format(schedule.dueSchedule)}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
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
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.green,
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => UpdateSchedulePage(
                                                scheduleData: {
                                                  'id': schedule.id,
                                                  'title':
                                                      schedule.scheduleName,
                                                  'description':
                                                      schedule.description,
                                                  'category_id':
                                                      schedule.categoryId,
                                                  'category':
                                                      schedule.categoryName,
                                                  'priority': schedule.priority,
                                                  'startDate':
                                                      schedule.startSchedule
                                                          .toIso8601String(),
                                                  'dueDate':
                                                      schedule.dueSchedule
                                                          .toIso8601String(),
                                                  'reminder':
                                                      schedule.beforeDueSchedule
                                                          .toIso8601String(),
                                                  'url': schedule.url,
                                                },
                                              ),
                                        ),
                                      );
                                      if (result == true) {
                                        // Refresh data setelah update
                                        scheduleProvider.loadSchedules(context);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                        context,
                                        schedule.id,
                                      );
                                    },
                                  ),
                                  if (schedule.status != 'completed')
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check_circle,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        _showMarkAsDoneConfirmationDialog(
                                          context,
                                          schedule.id,
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int scheduleId) {
    final parentContext = context; // Simpan context utama
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Schedule'),
          content: const Text('Are you sure you want to delete this schedule?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                try {
                  await Provider.of<ScheduleProvider>(
                    parentContext,
                    listen: false,
                  ).deleteSchedule(scheduleId, parentContext);
                  // Gunakan parentContext di sini!
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Schedule deleted successfully!'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text('Failed to delete schedule: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showMarkAsDoneConfirmationDialog(BuildContext context, int scheduleId) {
    final parentContext = context; // Simpan context utama
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark as Done'),
          content: const Text(
            'Are you sure you want to mark this schedule as done?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Mark as Done',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog dulu
                try {
                  await Provider.of<ScheduleProvider>(
                    parentContext,
                    listen: false,
                  ).markScheduleAsDone(
                    scheduleId,
                    parentContext,
                  ); // <-- gunakan parentContext
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Schedule marked as done!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text('Failed to mark schedule as done: $e'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
