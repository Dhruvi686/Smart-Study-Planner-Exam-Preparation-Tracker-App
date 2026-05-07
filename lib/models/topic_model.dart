import 'package:hive/hive.dart';

class TopicModel {
  final String id;
  final String subjectId;
  final String topicName;
  final String estimatedStudyTime;
  final String status;

  static const String notStarted = 'Not Started';
  static const String inProgress = 'In Progress';
  static const String completed = 'Completed';

  static const List<String> statusOptions = [
    notStarted,
    inProgress,
    completed,
  ];

  TopicModel({
    required this.id,
    required this.subjectId,
    required this.topicName,
    required this.estimatedStudyTime,
    required this.status,
  });
}

class TopicModelAdapter extends TypeAdapter<TopicModel> {
  @override
  final int typeId = 1;

  @override
  TopicModel read(BinaryReader reader) {
    return TopicModel(
      id: reader.readString(),
      subjectId: reader.readString(),
      topicName: reader.readString(),
      estimatedStudyTime: reader.readString(),
      status: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, TopicModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.subjectId)
      ..writeString(obj.topicName)
      ..writeString(obj.estimatedStudyTime)
      ..writeString(obj.status);
  }
}
