// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelsAdapter extends TypeAdapter<TaskModels> {
  @override
  final typeId = 0;

  @override
  TaskModels read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModels(
      id: (fields[0] as num).toInt(),
      taskName: fields[1] as String,
      taskDescription: fields[2] as String,
      isHighPriority: fields[3] as bool,
      isDone: fields[4] == null ? false : fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModels obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskName)
      ..writeByte(2)
      ..write(obj.taskDescription)
      ..writeByte(3)
      ..write(obj.isHighPriority)
      ..writeByte(4)
      ..write(obj.isDone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
