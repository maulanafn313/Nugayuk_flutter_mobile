// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailSchedulePage extends StatelessWidget {
  final String title;
  final String description;
  final String startDate;
  final String dueDate;
  final String reminder;
  final String status;
  final String url;
  final String category;
  final String priority;

  const DetailSchedulePage({
    super.key,
    required this.title,
    required this.description,
    required this.startDate,
    required this.dueDate,
    required this.reminder,
    required this.category,
    required this.priority,
    required this.status,
    this.url = '', // Default value for url
  });

  String _formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Details'),
        backgroundColor: const Color(0xFFB3E0FB), // Warna header
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFB3E0FB), // Warna field detail
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.title, color: Color(0xFF0A2472)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2472),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRowWithIcon(Icons.description, 'Description', description),
              _buildDetailRowWithIcon(Icons.category, 'Category', category),
              _buildDetailRowWithIcon(Icons.flag, 'Priority', _mapPriorityToDisplay(priority)),
              _buildDetailRowWithIcon(Icons.info, 'Status', status),
              _buildDetailRowWithIcon(Icons.calendar_today, 'Start Date', _formatDateTime(startDate)),
              _buildDetailRowWithIcon(Icons.event, 'Due Date', _formatDateTime(dueDate)),
              _buildDetailRowWithIcon(Icons.alarm, 'Reminder', _formatDateTime(reminder)),
              if (url.isNotEmpty) _buildDetailRowWithIcon(Icons.link, 'URL', url),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRowWithIcon(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Color(0xFF0A2472)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF0A2472),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}