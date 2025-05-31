// schedule_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule.dart';
import '../services/service.dart';
import 'notification_provider.dart';
import 'package:nugasyuk/auth_service.dart';


class ScheduleProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Schedule> _schedules = [];

  List<Schedule> get schedules => _schedules;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Getters for counts
  int get todoCount =>
      _schedules.where((s) => s.status.toLowerCase() == 'to-do').length;
  int get progressCount =>
      _schedules.where((s) => s.status.toLowerCase() == 'processed').length;
  int get completedCount =>
      _schedules.where((s) => s.status.toLowerCase() == 'completed').length;
  int get overdueCount =>
      _schedules.where((s) => s.status.toLowerCase() == 'overdue').length;

  Future<void> loadSchedules(BuildContext context) async {
    // Jangan set _isLoading atau _error di sini jika sudah ada di provider utama
    // Jika ini adalah bagian dari provider yang lebih besar, biarkan provider utama yang handle
    // Jika ini provider tunggal, maka:
    // _isLoading = true;
    // _error = null;
    // notifyListeners(); // Notify UI that loading has started

    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false); // Jika memanggil dari dalam provider lain
    scheduleProvider._isLoading = true;
    scheduleProvider._error = null;
    scheduleProvider.notifyListeners();


    try {
      // _schedules = await _apiService.fetchSchedules();
      scheduleProvider._schedules = await _apiService.fetchSchedules(); 
      debugPrint('ScheduleProvider: Schedules loaded: ${scheduleProvider._schedules.length}');
    } catch (e) {
      debugPrint('ScheduleProvider: Error loading schedules: $e');
      // _error = e.toString();
      // _schedules = [];
      scheduleProvider._error = e.toString();
      scheduleProvider._schedules = [];
    } finally {
      // _isLoading = false;
      // notifyListeners(); // Notify UI that loading is complete (success or fail)
      scheduleProvider._isLoading = false;
      scheduleProvider.notifyListeners();
    }
  }

  Future<void> addSchedule(Map<String, dynamic> newScheduleData, BuildContext context) async {
    try {
      final newSchedule = await _apiService.createSchedule(newScheduleData);
      _schedules.add(newSchedule);

      final userName = AuthService.currentUser?.name ?? 'A user';
        Provider.of<NotificationProvider>(context, listen: false).addNotification(
          title: 'Schedule Created',
          body: '$userName created the schedule "${newSchedule.scheduleName}".',
          userName: userName,
          scheduleName: newSchedule.scheduleName,
          action: 'created',
        );
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding schedule: $e');
      rethrow; // Lempar kembali error agar bisa ditangani di UI
    }
  }

  Future<void> updateSchedule(
    int id,
    Map<String, dynamic> updatedScheduleData,
    BuildContext context
  ) async {
    try {
      final updatedSchedule = await _apiService.updateSchedule(
        id,
        updatedScheduleData,
      );
      final index = _schedules.indexWhere((s) => s.id == id);
      if (index != -1) {
        _schedules[index] = updatedSchedule;

      final userName = AuthService.currentUser?.name ?? 'A user';
        Provider.of<NotificationProvider>(context, listen: false).addNotification(
          title: 'Schedule Updated',
          body: '$userName updated the schedule "${updatedSchedule.scheduleName}".',
          userName: userName,
          scheduleName: updatedSchedule.scheduleName,
          action: 'updated',
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating schedule: $e');
      rethrow;
    }
  }

  Future<void> deleteSchedule(int id, BuildContext context) async {
    try {
      final scheduleToDelete = _schedules.firstWhere((s) => s.id == id, orElse: () => Schedule(id: 0, scheduleName: "Unknown Schedule", categoryId: 0, categoryName: "", priority: "", status: "", startSchedule: DateTime.now(), dueSchedule: DateTime.now(), beforeDueSchedule: DateTime.now()));
      await _apiService.deleteSchedule(id);
      _schedules.removeWhere((s) => s.id == id);

      final userName = AuthService.currentUser?.name ?? 'A user';
      Provider.of<NotificationProvider>(context, listen: false).addNotification(
        title: 'Schedule Deleted',
        body: '$userName deleted the schedule "${scheduleToDelete.scheduleName}".',
        userName: userName,
        scheduleName: scheduleToDelete.scheduleName,
        action: 'deleted',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting schedule: $e');
      rethrow;
    }
  }

  Future<void> markScheduleAsDone(int id, BuildContext context) async {
    try {
      final updatedSchedule = await _apiService.markScheduleAsDone(id);
      final index = _schedules.indexWhere((s) => s.id == id);
      if (index != -1) {
        _schedules[index] = updatedSchedule;

        final userName = AuthService.currentUser?.name ?? 'A user';
          Provider.of<NotificationProvider>(context, listen: false).addNotification(
            title: 'Schedule Completed',
            body: '$userName completed the schedule "${updatedSchedule.scheduleName}".',
            userName: userName,
            scheduleName: updatedSchedule.scheduleName,
            action: 'completed',
          );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking schedule as done: $e');
      rethrow;
    }
  }

  
}
