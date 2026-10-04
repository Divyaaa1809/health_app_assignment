class SleepBreakdown {
  final Duration totalSleep;
  final Duration deepSleep;
  final Duration remSleep;
  final Duration lightSleep;
  final Duration awake;

  const SleepBreakdown({
    required this.totalSleep,
    required this.deepSleep,
    required this.remSleep,
    required this.lightSleep,
    required this.awake,
  });
}

class SleepCalculator {
  static SleepBreakdown calculate({
    required DateTime sleepStart,
    required DateTime sleepEnd,
  }) {
    // Handle sleep crossing midnight.
    var end = sleepEnd;

    if (!end.isAfter(sleepStart)) {
      end = end.add(const Duration(days: 1));
    }

    final total = end.difference(sleepStart);

    // Assumption for the assignment:
    // Deep = 25%
    // REM = 20%
    // Light = remaining 55%
    final deepMinutes = (total.inMinutes * 0.25).round();
    final remMinutes = (total.inMinutes * 0.20).round();
    final lightMinutes = total.inMinutes - deepMinutes - remMinutes;

    return SleepBreakdown(
      totalSleep: total,
      deepSleep: Duration(minutes: deepMinutes),
      remSleep: Duration(minutes: remMinutes),
      lightSleep: Duration(minutes: lightMinutes),
      awake: Duration.zero,
    );
  }
}
