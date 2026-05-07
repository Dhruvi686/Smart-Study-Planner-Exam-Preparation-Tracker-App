import 'package:flutter/material.dart';

import '../models/study_session_model.dart';
import '../services/hive_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService();
  final List<StudySessionModel> _sessions = [];

  List<StudySessionModel> get sessions => List.unmodifiable(_sessions);

  ScheduleProvider() {
    loadSessions();
  }

  Future<void> loadSessions() async {
    _sessions
      ..clear()
      ..addAll(_hiveService.getSessions());
    _sortSessions();
    notifyListeners();
  }

  Future<void> addSession({
    required String subjectId,
    required String subjectName,
    required String topicId,
    required String topicName,
    required DateTime date,
    required String time,
    required int durationMinutes,
  }) async {
    final newSession = StudySessionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subjectId: subjectId,
      subjectName: subjectName,
      topicId: topicId,
      topicName: topicName,
      date: date,
      time: time,
      durationMinutes: durationMinutes,
      isCompleted: false,
    );

    _sessions.add(newSession);
    _sortSessions();
    await _hiveService.addSession(newSession);
    notifyListeners();
  }

  Future<void> removeSession(String sessionId) async {
    _sessions.removeWhere((session) => session.id == sessionId);
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
      durationMinutes: old.durationMinutes,
      isCompleted: !old.isCompleted,
    );

    _sessions[index] = updated;
    await _hiveService.updateSession(updated);
    notifyListeners();
  }

  void _sortSessions() {
    _sessions.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.time.compareTo(b.time);
    });
  }
}
