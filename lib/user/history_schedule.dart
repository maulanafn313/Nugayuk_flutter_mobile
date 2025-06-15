import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'schedule_provider.dart';
import 'package:intl/intl.dart';
import 'detail_schedule.dart';
import 'dashboardpage.dart';

class HistorySchedulePage extends StatelessWidget {
  const HistorySchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final completedSchedules =
        scheduleProvider.schedules
            .where((schedule) => schedule.status == 'completed')
            .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF0A2472),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'History Schedule',
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
        child:
            completedSchedules.isEmpty
                ? const Center(
                  child: Text(
                    'No completed schedules.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF0A2472)),
                  ),
                )
                : ListView.builder(
                  itemCount: completedSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = completedSchedules[index];
                    return Card(
                      color: const Color(0xFFB3E0FB),
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
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text(
                                              'Delete Schedule',
                                            ),
                                            content: const Text(
                                              'Are you sure you want to delete this schedule?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(true),
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                    );
                                    if (confirm == true) {
                                      try {
                                        await Provider.of<ScheduleProvider>(
                                          context,
                                          listen: false,
                                        ).deleteSchedule(schedule.id, context);

                                        // Tampilkan alert/snackbar setelah berhasil hapus
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Schedule deleted successfully!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to delete schedule: $e',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
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
    );
  }
}
