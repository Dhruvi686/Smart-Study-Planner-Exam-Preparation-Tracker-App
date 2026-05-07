import 'package:hive_flutter/hive_flutter.dart';

import '../models/study_session_model.dart';
import '../models/subject_model.dart';
import '../models/topic_model.dart';

class HiveService {
  static const String subjectsBoxName = 'subjectsBox';
  static const String topicsBoxName = 'topicsBox';
  static const String sessionsBoxName = 'sessionsBox';

  static Future<void> initHive() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SubjectModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TopicModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(StudySessionModelAdapter());
    }

    // Open boxes safely (first launch / older box data).
    await _openBoxSafely<SubjectModel>(subjectsBoxName);
    await _openBoxSafely<TopicModel>(topicsBoxName);
    await _openBoxSafely<StudySessionModel>(sessionsBoxName);
  }

  static Future<void> _openBoxSafely<T>(String boxName) async {
    try {
      await Hive.openBox<T>(boxName);
    } catch (_) {
      // If something is corrupted/old format, recreate the box.
      await Hive.deleteBoxFromDisk(boxName);
      await Hive.openBox<T>(boxName);
    }
  }

  Box<SubjectModel> get _subjectsBox => Hive.box<SubjectModel>(subjectsBoxName);
  Box<TopicModel> get _topicsBox => Hive.box<TopicModel>(topicsBoxName);
  Box<StudySessionModel> get _sessionsBox =>
      Hive.box<StudySessionModel>(sessionsBoxName);

  Future<void> addSubject(SubjectModel subject) async {
    await _subjectsBox.put(subject.id, subject);
  }

  List<SubjectModel> getSubjects() {
    return _subjectsBox.values.toList();
  }

  Future<void> deleteSubject(String subjectId) async {
    await _subjectsBox.delete(subjectId);

    final topicKeysToDelete = _topicsBox.keys.where((key) {
      final topic = _topicsBox.get(key);
      return topic?.subjectId == subjectId;
    }).toList();

    for (final key in topicKeysToDelete) {
      await _topicsBox.delete(key);
    }

    // Also remove sessions that belong to the deleted subject.
    final sessionKeysToDelete = _sessionsBox.keys.where((key) {
      final session = _sessionsBox.get(key);
      return session?.subjectId == subjectId;
    }).toList();

    for (final key in sessionKeysToDelete) {
      await _sessionsBox.delete(key);
    }
  }

  Future<void> addTopic(TopicModel topic) async {
    await _topicsBox.put(topic.id, topic);
  }

  List<TopicModel> getTopics() {
    return _topicsBox.values.toList();
  }

  Future<void> updateTopic(TopicModel topic) async {
    await _topicsBox.put(topic.id, topic);
  }

  Future<void> deleteTopic(String topicId) async {
    await _topicsBox.delete(topicId);
  }

  Future<void> addSession(StudySessionModel session) async {
    await _sessionsBox.put(session.id, session);
  }

  List<StudySessionModel> getSessions() {
    return _sessionsBox.values.toList();
  }

  Future<void> deleteSession(String sessionId) async {
    await _sessionsBox.delete(sessionId);
  }

  Future<void> updateSession(StudySessionModel session) async {
    await _sessionsBox.put(session.id, session);
  }
}
