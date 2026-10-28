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
      dueDate: fields[5] as DateTime?,
      dueTime: fields[6] as String?,
      category: fields[7] as String? ?? 'General',
      priority: fields[8] == null
          ? ((fields[3] as bool? ?? false) ? 3 : 2)
          : (fields[8] as num).toInt(),
      rawSubtasks: (fields[9] as List?)?.cast<Map<dynamic, dynamic>>(),
      completedAt: fields[10] as DateTime?,
      createdAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModels obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskName)
      ..writeByte(2)
      ..write(obj.taskDescription)
      ..writeByte(3)
      ..write(obj.isHighPriority)
      ..writeByte(4)
      ..write(obj.isDone)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.dueTime)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.priority)
      ..writeByte(9)
      ..write(obj.rawSubtasks)
      ..writeByte(10)
      ..write(obj.completedAt)
      ..writeByte(11)
      ..write(obj.createdAt);
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
