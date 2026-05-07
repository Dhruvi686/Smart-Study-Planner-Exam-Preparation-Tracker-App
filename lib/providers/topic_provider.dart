import 'package:flutter/material.dart';

import '../models/subject_model.dart';
import '../models/topic_model.dart';
import '../services/hive_service.dart';
import 'subject_provider.dart';

class TopicProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService();

  Future<void> addTopic(
    SubjectModel subject,
    String topicName,
    String estimatedStudyTime,
    SubjectProvider subjectProvider,
  ) async {
    final trimmedName = topicName.trim();
    final trimmedTime = estimatedStudyTime.trim();

    if (trimmedName.isEmpty || trimmedTime.isEmpty) {
      return;
    }

    final newTopic = TopicModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subjectId: subject.id,
      topicName: trimmedName,
      estimatedStudyTime: trimmedTime,
      status: TopicModel.notStarted,
    );

    await _hiveService.addTopic(newTopic);
    await _syncSubjectsWithTopics(subjectProvider);
  }

  Future<void> removeTopic(
    SubjectModel subject,
    String topicId,
    SubjectProvider subjectProvider,
  ) async {
    await _hiveService.deleteTopic(topicId);
    await _syncSubjectsWithTopics(subjectProvider);
  }

  Future<void> updateStatus(
    SubjectModel subject,
    String topicId,
    String newStatus,
    SubjectProvider subjectProvider,
  ) async {
    if (!TopicModel.statusOptions.contains(newStatus)) {
      return;
    }

    final topic = _hiveService.getTopics().where((item) {
      return item.id == topicId && item.subjectId == subject.id;
    }).cast<TopicModel?>().firstWhere(
          (item) => item != null,
          orElse: () => null,
        );

    if (topic == null) {
      return;
    }

    final updatedTopic = TopicModel(
      id: topic.id,
      subjectId: topic.subjectId,
      topicName: topic.topicName,
      estimatedStudyTime: topic.estimatedStudyTime,
      status: newStatus,
    );

    await _hiveService.updateTopic(updatedTopic);
    await _syncSubjectsWithTopics(subjectProvider);
  }

  Future<void> _syncSubjectsWithTopics(SubjectProvider subjectProvider) async {
    final allSubjects = _hiveService.getSubjects();
    final allTopics = _hiveService.getTopics();

    final updatedSubjects = allSubjects.map((subject) {
      final subjectTopics =
          allTopics.where((topic) => topic.subjectId == subject.id).toList();

      return SubjectModel(
        id: subject.id,
        subjectName: subject.subjectName,
        topics: subjectTopics,
      );
    }).toList();

    subjectProvider.setSubjects(updatedSubjects);
    notifyListeners();
  }
}
