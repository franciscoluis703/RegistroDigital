// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityLogLocalAdapter extends TypeAdapter<ActivityLogLocal> {
  @override
  final int typeId = 0;

  @override
  ActivityLogLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityLogLocal(
      id: fields[0] as String,
      userId: fields[1] as String,
      action: fields[2] as String,
      entityType: fields[3] as String,
      entityId: fields[4] as String?,
      details: (fields[5] as Map?)?.cast<String, dynamic>(),
      timestamp: fields[6] as DateTime,
      synced: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityLogLocal obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.action)
      ..writeByte(3)
      ..write(obj.entityType)
      ..writeByte(4)
      ..write(obj.entityId)
      ..writeByte(5)
      ..write(obj.details)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLogLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
