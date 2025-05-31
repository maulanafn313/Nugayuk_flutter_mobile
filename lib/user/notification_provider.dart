// lib/user/notification_provider.dart
import 'package:flutter/material.dart';
import '../models/notificationmodel.dart'; 
import 'dart:math'; 

class NotificationProvider with ChangeNotifier {
  final List<NotificationMessage> _notifications = [];

  List<NotificationMessage> get notifications => List.unmodifiable(_notifications);
  List<NotificationMessage> get newNotifications => _notifications.where((n) => DateTime.now().difference(n.timestamp).inHours < 24).toList();
  List<NotificationMessage> get earlierNotifications => _notifications.where((n) => DateTime.now().difference(n.timestamp).inHours >= 24).toList();


  void addNotification({
    required String title,
    required String body,
    required String userName,
    required String scheduleName,
    required String action,
  }) {
    final newNotification = NotificationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString(), // Simple unique ID
      title: title,
      body: body,
      timestamp: DateTime.now(),
      userName: userName,
      scheduleName: scheduleName,
      action: action,
    );
    _notifications.insert(0, newNotification); 
    if (_notifications.length > 50) { 
      _notifications.removeLast();
    }
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}