import '../../domain/entities/sleep_data.dart';

class SleepModel {
  final String sleepStart;
  final String sleepEnd;
  final String deepStart;
  final String deepEnd;
  final String remStart;
  final String remEnd;
  final String lightStart;
  final String lightEnd;
  final List<Map<String, String>> awakePeriods;

  const SleepModel({
    required this.sleepStart,
    required this.sleepEnd,
    required this.deepStart,
    required this.deepEnd,
    required this.remStart,
    required this.remEnd,
    required this.lightStart,
    required this.lightEnd,
    required this.awakePeriods,
  });

  factory SleepModel.fromJson(Map<String, dynamic> json) {
    return SleepModel(
      sleepStart: json['sleepStart'] as String,
      sleepEnd: json['sleepEnd'] as String,
      deepStart: json['deepStart'] as String,
      deepEnd: json['deepEnd'] as String,
      remStart: json['remStart'] as String,
      remEnd: json['remEnd'] as String,
      lightStart: json['lightStart'] as String,
      lightEnd: json['lightEnd'] as String,
      awakePeriods: (json['awakePeriods'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'sleepStart': sleepStart,
        'sleepEnd': sleepEnd,
        'deepStart': deepStart,
        'deepEnd': deepEnd,
        'remStart': remStart,
        'remEnd': remEnd,
        'lightStart': lightStart,
        'lightEnd': lightEnd,
        'awakePeriods': awakePeriods,
      };

  SleepData toEntity() {
    SleepInterval interval(String start, String end) =>
        SleepInterval(start: DateTime.parse(start), end: DateTime.parse(end));

    return SleepData(
      sleepStart: DateTime.parse(sleepStart),
      sleepEnd: DateTime.parse(sleepEnd),
      deepSleep: interval(deepStart, deepEnd),
      remSleep: interval(remStart, remEnd),
      lightSleep: interval(lightStart, lightEnd),
      awakePeriods: awakePeriods
          .map((e) => interval(e['start']!, e['end']!))
          .toList(),
    );
  }

  factory SleepModel.fromEntity(SleepData entity) {
    Map<String, String> mapInterval(SleepInterval value) => {
          'start': value.start.toIso8601String(),
          'end': value.end.toIso8601String(),
        };

    return SleepModel(
      sleepStart: entity.sleepStart.toIso8601String(),
      sleepEnd: entity.sleepEnd.toIso8601String(),
      deepStart: entity.deepSleep.start.toIso8601String(),
      deepEnd: entity.deepSleep.end.toIso8601String(),
      remStart: entity.remSleep.start.toIso8601String(),
      remEnd: entity.remSleep.end.toIso8601String(),
      lightStart: entity.lightSleep.start.toIso8601String(),
      lightEnd: entity.lightSleep.end.toIso8601String(),
      awakePeriods: entity.awakePeriods.map(mapInterval).toList(),
    );
  }
}
