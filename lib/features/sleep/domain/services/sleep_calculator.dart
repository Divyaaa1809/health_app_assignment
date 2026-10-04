import '../entities/sleep_data.dart';

class SleepDataCalculator {
  const SleepDataCalculator();

  SleepData calculate({required DateTime start, required DateTime end}) {
    var actualEnd = end;

    // Handles overnight sleep.
    if (!actualEnd.isAfter(start)) {
      actualEnd = actualEnd.add(const Duration(days: 1));
    }

    final totalMinutes = actualEnd.difference(start).inMinutes;

    // Assignment assumption:
    // Deep = 25%
    // REM = 20%
    // Light = remaining 55%
    final deepMinutes = (totalMinutes * 0.25).round();
    final remMinutes = (totalMinutes * 0.20).round();
    final lightMinutes = totalMinutes - deepMinutes - remMinutes;

    final deepStart = start;
    final deepEnd = deepStart.add(Duration(minutes: deepMinutes));

    final remStart = deepEnd;
    final remEnd = remStart.add(Duration(minutes: remMinutes));

    final lightStart = remEnd;
    final lightEnd = lightStart.add(Duration(minutes: lightMinutes));

    return SleepData(
      sleepStart: start,
      sleepEnd: actualEnd,
      deepSleep: SleepInterval(start: deepStart, end: deepEnd),
      remSleep: SleepInterval(start: remStart, end: remEnd),
      lightSleep: SleepInterval(start: lightStart, end: lightEnd),
      awakePeriods: const [],
    );
  }
}
