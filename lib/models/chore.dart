// lib/models/chore.dart

import 'package:flutter/material.dart';

class Chore {
  int? id;
  String title;
  String? description;
  int pointValue;
  String frequency;       // 'daily', 'weekly', or 'one-time'
  List<int>? daysOfWeek;  // e.g. [1,3,5] if weekly
  TimeOfDay time;         // e.g. TimeOfDay(hour: 8, minute: 0)
  int? assignedChildId;   // ← NEW: which child this chore is assigned to

  Chore({
    this.id,
    required this.title,
    this.description,
    required this.pointValue,
    required this.frequency,
    this.daysOfWeek,
    required this.time,
    this.assignedChildId,
  });

  /// Convert Chore → Map<String, dynamic> for SQLite
  Map<String, dynamic> toMap() {
    // Convert TimeOfDay → "HH:mm" string:
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    final hh = twoDigits(time.hour);
    final mm = twoDigits(time.minute);
    final timeString = '$hh:$mm'; // e.g. "08:30"

    return {
      'id': id,
      'title': title,
      'description': description,
      'pointValue': pointValue,
      'frequency': frequency,
      'daysOfWeek': daysOfWeek != null
          ? daysOfWeek!.toString()   // stores "[1,2,3]" literally
          : null,
      'time': timeString,
      'assignedChildId': assignedChildId,
    };
  }

  /// Create Chore from a SQLite row map
  factory Chore.fromMap(Map<String, dynamic> m) {
    // Parse daysOfWeek from "[1,3,5]" → List<int>
    List<int>? days;
    if (m['daysOfWeek'] != null) {
      days = (m['daysOfWeek'] as String)
          .replaceAll(RegExp(r'[\[\]\s]'), '')
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.parse(s))
          .toList();
    }

    // Parse time string "HH:mm" → TimeOfDay
    final timeParts = (m['time'] as String).split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return Chore(
      id: m['id'] as int?,
      title: m['title'] as String,
      description: m['description'] as String?,
      pointValue: m['pointValue'] as int,
      frequency: m['frequency'] as String,
      daysOfWeek: days,
      time: TimeOfDay(hour: hour, minute: minute),
      assignedChildId: m['assignedChildId'] as int?,
    );
  }
}
