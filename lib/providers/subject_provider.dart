import 'package:flutter/material.dart';

import '../models/subject_model.dart';
import '../services/hive_service.dart';

class SubjectProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService();
  final List<SubjectModel> _subjects = [];

  List<SubjectModel> get subjects => List.unmodifiable(_subjects);

  SubjectProvider() {
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    final allSubjects = _hiveService.getSubjects();
    final allTopics = _hiveService.getTopics();

    final subjectsWithTopics = allSubjects.map((subject) {
      final subjectTopics =
          allTopics.where((topic) => topic.subjectId == subject.id).toList();

      return SubjectModel(
        id: subject.id,
        subjectName: subject.subjectName,
        topics: subjectTopics,
      );
    }).toList();

    _subjects
      ..clear()
      ..addAll(subjectsWithTopics);
    notifyListeners();
  }

  Future<void> addSubject(String subjectName) async {
    final trimmedName = subjectName.trim();

    if (trimmedName.isEmpty) {
      return;
    }

    final newSubject = SubjectModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subjectName: trimmedName,
    );

    _subjects.add(newSubject);
    await _hiveService.addSubject(newSubject);
    notifyListeners();
  }

  Future<void> removeSubject(String subjectId) async {
    _subjects.removeWhere((subject) => subject.id == subjectId);
    await _hiveService.deleteSubject(subjectId);
    notifyListeners();
  }

  void setSubjects(List<SubjectModel> subjects) {
    _subjects
      ..clear()
      ..addAll(subjects);
    notifyListeners();
  }
}
