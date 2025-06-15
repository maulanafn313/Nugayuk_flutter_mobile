// lib/user/notifications.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For formatting time
import 'notification_provider.dart'; // Your NotificationProvider
import '../models/notificationmodel.dart'; // Your NotificationMessage model
import '../auth_service.dart'; // To get current user for avatar initials
import 'dashboardpage.dart'; // Assuming you have a DashboardPage to navigate back to

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp); // e.g., May 29
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final newNotifications = notificationProvider.newNotifications;
    final earlierNotifications = notificationProvider.earlierNotifications;

    // Get current user's initials for avatar
    final currentUser = AuthService.currentUser;
    String avatarText = "N"; // Default
    if (currentUser != null && currentUser.name.isNotEmpty) {
      avatarText = currentUser.name.substring(0, 1).toUpperCase();
      if (currentUser.name.contains(" ") &&
          currentUser.name.split(" ").length > 1) {
        var parts = currentUser.name.split(" ");
        avatarText =
            parts[0].substring(0, 1).toUpperCase() +
            parts[1].substring(0, 1).toUpperCase();
      } else if (currentUser.name.length > 1) {
        avatarText = currentUser.name.substring(0, 2).toUpperCase();
      }
    }

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
          'Notifications',
          style: TextStyle(
            // color: Color(0xFF0A2472), // Will take from AppBarTheme
            fontWeight: FontWeight.bold,
          ),
        ),
        // backgroundColor: Colors.white, // Will take from AppBarTheme
        // elevation: 0, // Will take from AppBarTheme or default
        // iconTheme: const IconThemeData(color: Color(0xFF0A2472)), // Will take from AppBarTheme
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear all notifications',
            onPressed: () {
              if (notificationProvider.notifications.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No notifications to clear.')),
                );
                return;
              }
              showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('Clear Notifications'),
                      content: const Text(
                        'Are you sure you want to delete all notifications? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        TextButton(
                          child: const Text(
                            'Clear All',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            Provider.of<NotificationProvider>(
                              context,
                              listen: false,
                            ).clearNotifications();
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All notifications cleared.'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body:
          notificationProvider.notifications.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No notifications yet.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    Text(
                      'Create, update, or complete tasks to see notifications here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  if (newNotifications.isNotEmpty) ...[
                    const SectionTitle(title: 'New'),
                    ...newNotifications.map(
                      (notification) => NotificationItem(
                        // avatarColor: _getColorForAction(notification.action),
                        avatarText: avatarText, // Use dynamic initials
                        name:
                            notification.userName, // User who performed action
                        action: notification.action,
                        taskName: notification.scheduleName,
                        time: _formatTimeAgo(notification.timestamp),
                        messageBody: notification.body,
                      ),
                    ),
                  ],
                  if (earlierNotifications.isNotEmpty) ...[
                    const SectionTitle(title: 'Earlier'),
                    ...earlierNotifications.map(
                      (notification) => NotificationItem(
                        // avatarColor: _getColorForAction(notification.action),
                        avatarText: avatarText,
                        name: notification.userName,
                        action: notification.action,
                        taskName: notification.scheduleName,
                        time: _formatTimeAgo(notification.timestamp),
                        messageBody: notification.body,
                      ),
                    ),
                  ],
                ],
              ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ), // Added horizontal padding
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary, // Use theme color
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  // final Color avatarColor; // Can be dynamic based on action type
  final String avatarText;
  final String name;
  final String action;
  final String taskName;
  final String time;
  final String messageBody; // Full message

  const NotificationItem({
    // required this.avatarColor,
    required this.avatarText,
    required this.name,
    required this.action,
    required this.taskName,
    required this.time,
    required this.messageBody,
    super.key,
  });

  IconData _getIconForAction(String action) {
    switch (action.toLowerCase()) {
      case 'created':
        return Icons.add_circle_outline;
      case 'updated':
        return Icons.edit_note_outlined;
      case 'deleted':
        return Icons.delete_outline;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _getColorForAction(String action, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    switch (action.toLowerCase()) {
      case 'created':
        return colors.primary; // Blue
      case 'updated':
        return colors.secondary; // Orange/Teal like
      case 'deleted':
        return colors.error; // Red
      case 'completed':
        return Colors.green; // Green
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color actionColor = _getColorForAction(action, context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: actionColor.withOpacity(0.2),
              child: Icon(
                _getIconForAction(action),
                color: actionColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageBody, // Display the full message body
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87, // Slightly dimmer than pure black
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
