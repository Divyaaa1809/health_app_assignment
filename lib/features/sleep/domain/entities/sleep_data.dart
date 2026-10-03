import 'package:equatable/equatable.dart';

class SleepData extends Equatable {
  final DateTime startTime;
  final DateTime endTime;
  final Duration deepSleep;
  final Duration remSleep;
  final Duration lightSleep;
  final Duration awakeTime;

  const SleepData({
    required this.startTime,
    required this.endTime,
    required this.deepSleep,
    required this.remSleep,
    required this.lightSleep,
    required this.awakeTime,
  });

  Duration get totalSleep =>
      endTime.difference(startTime) - awakeTime;

  @override
  List<Object?> get props => [
        startTime,
        endTime,
        deepSleep,
        remSleep,
        lightSleep,
        awakeTime,
      ];
}
