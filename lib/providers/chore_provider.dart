// lib/providers/chore_provider.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chore.dart';
import '../services/db_helper.dart';
import '../services/notification_services.dart';

class ChoreProvider extends ChangeNotifier {
  List<Chore> _chores = [];
  final DBHelper _dbHelper = DBHelper();
  final NotificationService _notifService = NotificationService();

  List<Chore> get chores => _chores;

  Future<void> loadChores() async {
    final List<Map<String, dynamic>> maps = await _dbHelper.fetchAllChores();
    _chores = maps.map((map) => Chore.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addChore(Chore chore) async {
    final id = await _dbHelper.insertChore(chore.toMap());
    chore.id = id;
    _chores.add(chore);

    // Schedule notifications, now using TimeOfDay directly:
    if (chore.frequency == 'daily') {
      await _notifService.scheduleDailyNotification(
        id: id,
        title: 'Chore Reminder',
        body: 'Time to "${chore.title}"!  +${chore.pointValue} pts',
        time: chore.time,
      );
    } else if (chore.frequency == 'weekly' && chore.daysOfWeek != null) {
      await _notifService.scheduleWeeklyNotification(
        id: id,
        title: 'Chore Reminder',
        body: 'Time to "${chore.title}"!  +${chore.pointValue} pts',
        time: chore.time,
        days: chore.daysOfWeek!,
      );
    } else if (chore.frequency == 'one-time') {
      final now = DateTime.now();
      DateTime scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        chore.time.hour,
        chore.time.minute,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _notifService.scheduleOneTimeNotification(
        id: id,
        title: 'Chore Reminder',
        body: 'Time to "${chore.title}"!  +${chore.pointValue} pts',
        scheduledDate: scheduled,
      );
    }

    notifyListeners();
  }

  Future<void> updateChore(Chore chore) async {
    if (chore.id == null) return;

    // Cancel existing
    await _notifService.cancelNotification(chore.id!);
    if (chore.frequency == 'weekly' && chore.daysOfWeek != null) {
      for (int d in chore.daysOfWeek!) {
        await _notifService.cancelNotification(chore.id! * 10 + d);
      }
    }

    // Update DB
    await _dbHelper.updateChore(chore.id!, chore.toMap());

    // Reschedule (same logic as addChore)
    if (chore.frequency == 'daily') {
      await _notifService.scheduleDailyNotification(
        id: chore.id!,
        title: 'Chore Reminder',
        body: 'Time to "${chore.title}"!  +${chore.pointValue} pts',
        time: chore.time,
      );
    } else if (chore.frequency == 'weekly' && chore.daysOfWeek != null) {
      await _notifService.scheduleWeeklyNotification(
        id: chore.id!,
        title: 'Chore Reminder',
        body: 'Time to "${chore.title}"!  +${chore.pointValue} pts',
        time: chore.time,
        days: chore.daysOfWeek!,
      );
    } else if (chore.frequency == 'one-time') {
      final now = DateTime.now();
      DateTime scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        chore.time.hour,
        chore.time.minute,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _notifService.scheduleOneTimeNotification(
        id: chore.id!,
        title: 'Chore Reminder',
        body: 'Time to "${chore.title}"!  +${chore.pointValue} pts',
        scheduledDate: scheduled,
      );
    }

    await loadChores();
  }

  Future<void> deleteChore(int id) async {
    await _dbHelper.deleteChore(id);
    await _notifService.cancelNotification(id);
    _chores.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<List<Chore>> fetchTodayChores() async {
    final allMaps = await _dbHelper.fetchAllChores();
    final List<Chore> todayChores = [];
    final now = DateTime.now();
    final weekday = now.weekday;

    for (var m in allMaps) {
      final chore = Chore.fromMap(m);
      if (chore.frequency == 'daily') {
        todayChores.add(chore);
      } else if (chore.frequency == 'weekly' && chore.daysOfWeek != null) {
        if (chore.daysOfWeek!.contains(weekday)) {
          todayChores.add(chore);
        }
      } else if (chore.frequency == 'one-time') {
        todayChores.add(chore);
      }
    }

    return todayChores;
  }
}
