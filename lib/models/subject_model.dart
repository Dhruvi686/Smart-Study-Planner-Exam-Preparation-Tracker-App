import 'package:hive/hive.dart';

import 'topic_model.dart';

class SubjectModel {
  final String id;
  final String subjectName;
  final List<TopicModel> topics;

  SubjectModel({
    required this.id,
    required this.subjectName,
    List<TopicModel>? topics,
  }) : topics = topics ?? [];
}

class SubjectModelAdapter extends TypeAdapter<SubjectModel> {
  @override
  final int typeId = 0;

  @override
  SubjectModel read(BinaryReader reader) {
    return SubjectModel(
      id: reader.readString(),
      subjectName: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, SubjectModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.subjectName);
  }
}
