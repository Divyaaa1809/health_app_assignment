import '../../domain/entities/sleep_data.dart';

class SleepModel {
  final DateTime startTime;
  final DateTime endTime;
  final int deepMinutes;
  final int remMinutes;
  final int lightMinutes;
  final int awakeMinutes;

  const SleepModel({
    required this.startTime,
    required this.endTime,
    required this.deepMinutes,
    required this.remMinutes,
    required this.lightMinutes,
    required this.awakeMinutes,
  });

  factory SleepModel.fromJson(Map<String, dynamic> json) {
    return SleepModel(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      deepMinutes: (json['deepMinutes'] as num).toInt(),
      remMinutes: (json['remMinutes'] as num).toInt(),
      lightMinutes: (json['lightMinutes'] as num).toInt(),
      awakeMinutes: (json['awakeMinutes'] as num).toInt(),
    );
  }

  factory SleepModel.fromEntity(SleepData data) => SleepModel(
        startTime: data.startTime,
        endTime: data.endTime,
        deepMinutes: data.deepSleep.inMinutes,
        remMinutes: data.remSleep.inMinutes,
        lightMinutes: data.lightSleep.inMinutes,
        awakeMinutes: data.awakeTime.inMinutes,
      );

  Map<String, dynamic> toJson() => {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'deepMinutes': deepMinutes,
        'remMinutes': remMinutes,
        'lightMinutes': lightMinutes,
        'awakeMinutes': awakeMinutes,
      };

  SleepData toEntity() => SleepData(
        startTime: startTime,
        endTime: endTime,
        deepSleep: Duration(minutes: deepMinutes),
        remSleep: Duration(minutes: remMinutes),
        lightSleep: Duration(minutes: lightMinutes),
        awakeTime: Duration(minutes: awakeMinutes),
      );
}
