import 'package:equatable/equatable.dart';

class SleepInterval extends Equatable {
  final DateTime start;
  final DateTime end;

  const SleepInterval({required this.start, required this.end});

  Duration get duration => end.difference(start);

  @override
  List<Object?> get props => [start, end];
}

class SleepData extends Equatable {
  final DateTime sleepStart;
  final DateTime sleepEnd;
  final SleepInterval deepSleep;
  final SleepInterval remSleep;
  final SleepInterval lightSleep;
  final List<SleepInterval> awakePeriods;

  const SleepData({
    required this.sleepStart,
    required this.sleepEnd,
    required this.deepSleep,
    required this.remSleep,
    required this.lightSleep,
    required this.awakePeriods,
  });

  Duration get totalSession => sleepEnd.difference(sleepStart);

  Duration get awakeTime => awakePeriods.fold(
        Duration.zero,
        (total, period) => total + period.duration,
      );

  Duration get totalSleep => totalSession - awakeTime;

  Duration get stagedSleep =>
      deepSleep.duration + remSleep.duration + lightSleep.duration;

  bool get isBalanced => stagedSleep == totalSleep;

  SleepData copyWith({
    DateTime? sleepStart,
    DateTime? sleepEnd,
    SleepInterval? deepSleep,
    SleepInterval? remSleep,
    SleepInterval? lightSleep,
    List<SleepInterval>? awakePeriods,
  }) {
    return SleepData(
      sleepStart: sleepStart ?? this.sleepStart,
      sleepEnd: sleepEnd ?? this.sleepEnd,
      deepSleep: deepSleep ?? this.deepSleep,
      remSleep: remSleep ?? this.remSleep,
      lightSleep: lightSleep ?? this.lightSleep,
      awakePeriods: awakePeriods ?? this.awakePeriods,
    );
  }

  @override
  List<Object?> get props => [
        sleepStart,
        sleepEnd,
        deepSleep,
        remSleep,
        lightSleep,
        awakePeriods,
      ];
}
