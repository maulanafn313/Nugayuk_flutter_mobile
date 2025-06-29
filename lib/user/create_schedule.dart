import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'schedule_provider.dart';
import 'category_provider.dart';
// import '../models/schedule.dart';
// import '../models/category.dart';

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({super.key});

  @override
  _CreateSchedulePageState createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  String? taskType;
  String? importance;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? reminderDate; // Ini akan digunakan untuk before_due_schedule
  int? selectedCategoryId;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load categories saat halaman dibuka
    Future.microtask(
      () =>
          Provider.of<CategoryProvider>(
            context,
            listen: false,
          ).loadCategories(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Schedule', style: TextStyle(fontWeight: FontWeight.bold,)),
        backgroundColor: const Color(0xFFB3E0FB), // Ubah warna header
        foregroundColor: Color(0xFF0A2472),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule Title',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFB3E0FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // Lebih melengkung
                  ),
                  hintText: 'Enter schedule title',
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFB3E0FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: 'Enter description',
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              categoryProvider.categories.isEmpty
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<int>(
                      value: selectedCategoryId,
                      items: categoryProvider.categories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => selectedCategoryId = value),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFB3E0FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: 'Select Category',
                        prefixIcon: const Icon(Icons.category),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 16),
              const Text(
                'Priority',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: importance,
                items: [
                  'very_important',
                  'important',
                  'not_important',
                ]
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(_mapPriorityToDisplay(e)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => importance = value),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFB3E0FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: 'Select Priority',
                  prefixIcon: const Icon(Icons.flag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a priority';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Start Date & Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickDateTime(context, 'start'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3E0FB),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.black54),
                      const SizedBox(width: 12),
                      Text(
                        startDate != null
                            ? '${startDate!.day}/${startDate!.month}/${startDate!.year} ${startDate!.hour}:${startDate!.minute.toString().padLeft(2, '0')}'
                            : 'Select start date & time',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'End Date & Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickDateTime(context, 'end'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3E0FB),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: Colors.black54),
                      const SizedBox(width: 12),
                      Text(
                        endDate != null
                            ? '${endDate!.day}/${endDate!.month}/${endDate!.year} ${endDate!.hour}:${endDate!.minute.toString().padLeft(2, '0')}'
                            : 'Select end date & time',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reminder Date & Time (Before Due)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickDateTime(context, 'reminder'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3E0FB),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.alarm, color: Colors.black54),
                      const SizedBox(width: 12),
                      Text(
                        reminderDate != null
                            ? '${reminderDate!.day}/${reminderDate!.month}/${reminderDate!.year} ${reminderDate!.hour}:${reminderDate!.minute.toString().padLeft(2, '0')}'
                            : 'Select reminder date & time',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('URL', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: urlController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFB3E0FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: 'Enter URL (optional)',
                  prefixIcon: const Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (startDate == null ||
                        endDate == null ||
                        reminderDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select start, end, and reminder dates',
                          ),
                        ),
                      );
                      return;
                    }
                    if (reminderDate!.isAfter(endDate!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Reminder date must be before due date!',
                          ),
                        ),
                      );
                      return;
                    }

                    final newScheduleData = {
                      'schedule_name': titleController.text,
                      'description': descriptionController.text,
                      'category_id' : selectedCategoryId,
                      'priority':
                          importance ??
                          'not_important', // Default ke 'not_important' jika tidak dipilih
                      'start_schedule': startDate!.toIso8601String(),
                      'due_schedule': endDate!.toIso8601String(),
                      'before_due_schedule': reminderDate!.toIso8601String(),
                      'url':
                          urlController.text.isEmpty ? '' : urlController.text,
                    };

                    try {
                      await Provider.of<ScheduleProvider>(
                        context,
                        listen: false,
                      ).addSchedule(newScheduleData, context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Schedule created successfully!'),
                        ),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating schedule: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2472),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Center(
                  child: Text(
                    'Create Schedule',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context, String type) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (type == 'start') {
        startDate = dateTime;
      } else if (type == 'end') {
        endDate = dateTime;
      } else if (type == 'reminder') {
        reminderDate = dateTime;
      }
    });
  }

  String _mapPriorityToDisplay(String priority) {
    switch (priority) {
      case 'very_important':
        return 'Very Important';
      case 'important':
        return 'Important';
      case 'not_important':
        return 'Not Important';
      default:
        return priority;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    urlController.dispose();
    super.dispose();
  }
}
