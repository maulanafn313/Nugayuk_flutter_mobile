// lib/models/notification_model.dart
class NotificationMessage {
  final String id; // Unique ID for the notification
  final String title; // e.g., "Schedule Created"
  final String body;  // e.g., "Schedule 'Team Meeting' was created."
  final DateTime timestamp;
  final String userName; // User who performed the action
  final String scheduleName; // Name of the affected schedule
  final String action; // "created", "updated", "deleted", "completed"

  NotificationMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.userName,
    required this.scheduleName,
    required this.action,
  });
}