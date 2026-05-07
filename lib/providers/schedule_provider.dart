import 'dart:async';

import 'package:flutter/material.dart';

import '../models/study_session_model.dart';
import '../services/hive_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService();
  final List<StudySessionModel> _sessions = [];
  final Map<String, Timer> _reminderTimers = {};

  String? _lastReminder;

  String? get lastReminder => _lastReminder;

  void clearReminder() {
    _lastReminder = null;
    notifyListeners();
  }

  List<StudySessionModel> get sessions => List.unmodifiable(_sessions);

  ScheduleProvider() {
    loadSessions();
  }

  Future<void> loadSessions() async {
    _sessions
      ..clear()
      ..addAll(_hiveService.getSessions());
    _sortSessions();
    _scheduleUpcomingReminders();
    notifyListeners();
  }

  Future<void> addSession({
    required String subjectId,
    required String subjectName,
    required String topicId,
    required String topicName,
    required DateTime date,
    required String time,
    required int timeMinutes,
    required int durationMinutes,
  }) async {
    // Safety: we only allow "today" sessions.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pickedDate = DateTime(date.year, date.month, date.day);
    if (pickedDate != today) {
      return;
    }

    final newSession = StudySessionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subjectId: subjectId,
      subjectName: subjectName,
      topicId: topicId,
      topicName: topicName,
      date: date,
      time: time,
      timeMinutes: timeMinutes,
      durationMinutes: durationMinutes,
      isCompleted: false,
    );

    _sessions.add(newSession);
    _sortSessions();
    await _hiveService.addSession(newSession);
    _scheduleReminderForSession(newSession);
    notifyListeners();
  }

  Future<void> removeSession(String sessionId) async {
    _sessions.removeWhere((session) => session.id == sessionId);
    _cancelReminder(sessionId);
    await _hiveService.deleteSession(sessionId);
    notifyListeners();
  }

  Future<void> toggleComplete(String sessionId) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;

    final old = _sessions[index];

    final updated = StudySessionModel(
      id: old.id,
      subjectId: old.subjectId,
      subjectName: old.subjectName,
      topicId: old.topicId,
      topicName: old.topicName,
      time: old.time,
      date: old.date,
      timeMinutes: old.timeMinutes,
      durationMinutes: old.durationMinutes,
      isCompleted: !old.isCompleted,
    );

    _sessions[index] = updated;
    await _hiveService.updateSession(updated);

    if (updated.isCompleted) {
      _cancelReminder(updated.id);
    } else {
      _scheduleReminderForSession(updated);
    }

    notifyListeners();
  }

  void _sortSessions() {
    _sessions.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.timeMinutes.compareTo(b.timeMinutes);
    });
  }

  void _cancelReminder(String sessionId) {
    final timer = _reminderTimers.remove(sessionId);
    timer?.cancel();
  }

  void _scheduleUpcomingReminders() {
    // Cancel existing timers and reschedule from current list.
    for (final timer in _reminderTimers.values) {
      timer.cancel();
    }
    _reminderTimers.clear();

    for (final session in _sessions) {
      if (session.isCompleted) continue;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final pickedDate = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      if (pickedDate != today) continue;

      _scheduleReminderForSession(session);
    }
  }

  void _scheduleReminderForSession(StudySessionModel session) {
    final now = DateTime.now();
    final scheduledDateTime = _buildScheduledDateTime(session);

    // Only schedule if it's still in the future.
    if (scheduledDateTime.isBefore(now) || scheduledDateTime.isAtSameMomentAs(now)) {
      return;
    }

    // Avoid duplicate scheduling
    _cancelReminder(session.id);

    final delay = scheduledDateTime.difference(now);
    _reminderTimers[session.id] = Timer(delay, () {
      _lastReminder =
          'Time for ${session.subjectName} • ${session.topicName}';
      notifyListeners();
    });
  }

  DateTime _buildScheduledDateTime(StudySessionModel session) {
    final hour = session.timeMinutes ~/ 60;
    final minute = session.timeMinutes % 60;

    return DateTime(
      session.date.year,
      session.date.month,
      session.date.day,
      hour,
      minute,
    );
  }
}
