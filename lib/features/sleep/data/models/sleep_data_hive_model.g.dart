// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_data_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepDataHiveModelAdapter extends TypeAdapter<SleepDataHiveModel> {
  @override
  final int typeId = 10;

  @override
  SleepDataHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepDataHiveModel(
      sleepStart: fields[0] as DateTime,
      sleepEnd: fields[1] as DateTime,
      deepStart: fields[2] as DateTime,
      deepEnd: fields[3] as DateTime,
      remStart: fields[4] as DateTime,
      remEnd: fields[5] as DateTime,
      lightStart: fields[6] as DateTime,
      lightEnd: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SleepDataHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.sleepStart)
      ..writeByte(1)
      ..write(obj.sleepEnd)
      ..writeByte(2)
      ..write(obj.deepStart)
      ..writeByte(3)
      ..write(obj.deepEnd)
      ..writeByte(4)
      ..write(obj.remStart)
      ..writeByte(5)
      ..write(obj.remEnd)
      ..writeByte(6)
      ..write(obj.lightStart)
      ..writeByte(7)
      ..write(obj.lightEnd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepDataHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
