import 'package:hive/hive.dart';

class StudySessionModel {
  final String id;
  final String subjectId;
  final String subjectName;
  final String topicId;
  final String topicName;
  final String time;
  final DateTime date;
  final int durationMinutes;
  final bool isCompleted;

  StudySessionModel({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.topicId,
    required this.topicName,
    required this.time,
    required this.date,
    required this.durationMinutes,
    required this.isCompleted,
  });
}

class StudySessionModelAdapter extends TypeAdapter<StudySessionModel> {
  @override
  final int typeId = 2;

  @override
  StudySessionModel read(BinaryReader reader) {
    // Backward-friendly read: older data might not have the last fields.
    return StudySessionModel(
      id: reader.readString(),
      subjectId: reader.readString(),
      subjectName: reader.readString(),
      topicId: reader.readString(),
      topicName: reader.readString(),
      time: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      durationMinutes: reader.availableBytes > 0 ? reader.readInt() : 0,
      isCompleted: reader.availableBytes > 0 ? reader.readBool() : false,
    );
  }

  @override
  void write(BinaryWriter writer, StudySessionModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.subjectId)
      ..writeString(obj.subjectName)
      ..writeString(obj.topicId)
      ..writeString(obj.topicName)
      ..writeString(obj.time)
      ..writeInt(obj.date.millisecondsSinceEpoch)
      ..writeInt(obj.durationMinutes)
      ..writeBool(obj.isCompleted);
  }
}
