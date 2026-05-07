import 'package:flutter/material.dart';

import '../models/topic_model.dart';
import 'subject_provider.dart';

class SearchResultItem {
  final String subjectName;
  final String topicId;
  final String topicName;
  final String estimatedStudyTime;
  final String status;
  final double progress; // 0.0 - 1.0

  SearchResultItem({
    required this.subjectName,
    required this.topicId,
    required this.topicName,
    required this.estimatedStudyTime,
    required this.status,
    required this.progress,
  });
}

class SearchProvider extends ChangeNotifier {
  String _query = '';
  String _selectedSubject = 'All';
  String _selectedStatus = 'All';
  String _progressFilter = 'All'; // All | <50 | >50

  String get query => _query;
  String get selectedSubject => _selectedSubject;
  String get selectedStatus => _selectedStatus;
  String get progressFilter => _progressFilter;

  void searchTopics(String value) {
    _query = value;
    notifyListeners();
  }

  void filterBySubject(String value) {
    _selectedSubject = value;
    notifyListeners();
  }

  void filterByStatus(String value) {
    _selectedStatus = value;
    notifyListeners();
  }

  void filterByProgress(String value) {
    _progressFilter = value;
    notifyListeners();
  }

  void resetFilters() {
    _query = '';
    _selectedSubject = 'All';
    _selectedStatus = 'All';
    _progressFilter = 'All';
    notifyListeners();
  }

  List<SearchResultItem> getFilteredResults(SubjectProvider subjectProvider) {
    final results = <SearchResultItem>[];

    for (final subject in subjectProvider.subjects) {
      for (final topic in subject.topics) {
        results.add(
          SearchResultItem(
            subjectName: subject.subjectName,
            topicId: topic.id,
            topicName: topic.topicName,
            estimatedStudyTime: topic.estimatedStudyTime,
            status: topic.status,
            progress: _topicProgress(topic.status),
          ),
        );
      }
    }

    return results.where(_matchesFilters).toList();
  }

  bool _matchesFilters(SearchResultItem item) {
    if (_selectedSubject != 'All' && item.subjectName != _selectedSubject) {
      return false;
    }

    if (_selectedStatus != 'All' && item.status != _selectedStatus) {
      return false;
    }

    if (_progressFilter == '<50' && (item.progress * 100) >= 50) {
      return false;
    }

    if (_progressFilter == '>50' && (item.progress * 100) <= 50) {
      return false;
    }

    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return true;
    }

    final subjectName = item.subjectName.toLowerCase();
    final topicName = item.topicName.toLowerCase();

    return subjectName.contains(q) || topicName.contains(q);
  }

  double _topicProgress(String status) {
    // Simple "progress" mapping for each topic.
    // Completed = 100%, In Progress = 50%, Not Started = 0%.
    if (status == TopicModel.completed) {
      return 1.0;
    }
    if (status == TopicModel.inProgress) {
      return 0.5;
    }
    return 0.0;
  }
}
