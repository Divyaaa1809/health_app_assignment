import 'package:hive/hive.dart';

import '../../domain/entities/sleep_data.dart';

part 'sleep_data_hive_model.g.dart';

@HiveType(typeId: 10)
class SleepDataHiveModel extends HiveObject {
  @HiveField(0)
  final DateTime sleepStart;

  @HiveField(1)
  final DateTime sleepEnd;

  @HiveField(2)
  final DateTime deepStart;

  @HiveField(3)
  final DateTime deepEnd;

  @HiveField(4)
  final DateTime remStart;

  @HiveField(5)
  final DateTime remEnd;

  @HiveField(6)
  final DateTime lightStart;

  @HiveField(7)
  final DateTime lightEnd;

  SleepDataHiveModel({
    required this.sleepStart,
    required this.sleepEnd,
    required this.deepStart,
    required this.deepEnd,
    required this.remStart,
    required this.remEnd,
    required this.lightStart,
    required this.lightEnd,
  });

  factory SleepDataHiveModel.fromEntity(SleepData data) {
    return SleepDataHiveModel(
      sleepStart: data.sleepStart,
      sleepEnd: data.sleepEnd,
      deepStart: data.deepSleep.start,
      deepEnd: data.deepSleep.end,
      remStart: data.remSleep.start,
      remEnd: data.remSleep.end,
      lightStart: data.lightSleep.start,
      lightEnd: data.lightSleep.end,
    );
  }

  SleepData toEntity() {
    return SleepData(
      sleepStart: sleepStart,
      sleepEnd: sleepEnd,
      deepSleep: SleepInterval(start: deepStart, end: deepEnd),
      remSleep: SleepInterval(start: remStart, end: remEnd),
      lightSleep: SleepInterval(start: lightStart, end: lightEnd),
      awakePeriods: const [],
    );
  }
}
