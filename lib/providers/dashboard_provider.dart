import 'package:flutter/material.dart';

import '../models/subject_model.dart';
import '../models/topic_model.dart';
import 'subject_provider.dart';

class StudySession {
  final String subjectName;
  final String topicName;
  final String time;

  StudySession({
    required this.subjectName,
    required this.topicName,
    required this.time,
  });
}

class SubjectProgress {
  final String subjectName;
  final double progress;

  SubjectProgress({
    required this.subjectName,
    required this.progress,
  });
}

class DashboardProvider extends ChangeNotifier {
  final List<StudySession> _todaySessions = [];

  List<StudySession> get todaySessions => List.unmodifiable(_todaySessions);

  // You can call this from your ScheduleProvider later.
  void setTodaySessions(List<StudySession> sessions) {
    _todaySessions
      ..clear()
      ..addAll(sessions);
    notifyListeners();
  }

  int calculateTotalSubjects(SubjectProvider subjectProvider) {
    return subjectProvider.subjects.length;
  }

  int calculateTotalTopics(SubjectProvider subjectProvider) {
    int count = 0;
    for (final subject in subjectProvider.subjects) {
      count += subject.topics.length;
    }
    return count;
  }

  int calculateCompletedTopics(SubjectProvider subjectProvider) {
    int count = 0;
    for (final subject in subjectProvider.subjects) {
      count += subject.topics
          .where((topic) => topic.status == TopicModel.completed)
          .length;
    }
    return count;
  }

  int calculatePendingTopics(SubjectProvider subjectProvider) {
    final totalTopics = calculateTotalTopics(subjectProvider);
    final completedTopics = calculateCompletedTopics(subjectProvider);
    return totalTopics - completedTopics;
  }

  double calculateCompletionPercentage(SubjectProvider subjectProvider) {
    final totalTopics = calculateTotalTopics(subjectProvider);

    if (totalTopics == 0) {
      return 0;
    }

    final completedTopics = calculateCompletedTopics(subjectProvider);
    return (completedTopics / totalTopics) * 100;
  }

  List<SubjectProgress> getWeakSubjects(SubjectProvider subjectProvider) {
    final subjects = subjectProvider.subjects;
    final List<SubjectProgress> result = [];

    for (final subject in subjects) {
      final progress = _getSubjectCompletion(subject);
      result.add(
        SubjectProgress(
          subjectName: subject.subjectName,
          progress: progress,
        ),
      );
    }

    result.sort((a, b) => a.progress.compareTo(b.progress));
    return result;
  }

  Map<String, String>? getNextRecommendedTopic(SubjectProvider subjectProvider) {
    final weakSubjects = getWeakSubjects(subjectProvider);

    for (final weakSubject in weakSubjects) {
      final subject = subjectProvider.subjects.firstWhere(
        (item) => item.subjectName == weakSubject.subjectName,
      );

      final firstIncompleteTopic = subject.topics.where((topic) {
        return topic.status != TopicModel.completed;
      }).cast<TopicModel?>().firstWhere(
            (topic) => topic != null,
            orElse: () => null,
          );

      if (firstIncompleteTopic != null) {
        return {
          'subjectName': subject.subjectName,
          'topicName': firstIncompleteTopic.topicName,
          'reason': 'Low progress subject',
        };
      }
    }

    return null;
  }

  double _getSubjectCompletion(SubjectModel subject) {
    if (subject.topics.isEmpty) {
      return 0;
    }

    final completedCount = subject.topics
        .where((topic) => topic.status == TopicModel.completed)
        .length;
    return completedCount / subject.topics.length;
  }
}
