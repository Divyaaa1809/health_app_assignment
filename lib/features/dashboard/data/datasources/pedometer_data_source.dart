import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'dashboard_local_data_source.dart';

abstract class PedometerDataSource {
  Stream<int> get dailyStepsStream;
}

class DevicePedometerDataSource implements PedometerDataSource {
  final DashboardLocalDataSource local;
  late final Stream<int> _stream;

  DevicePedometerDataSource(this.local) {
    _stream = Pedometer.stepCountStream.asyncMap(_toDailySteps);
  }

  Future<int> _toDailySteps(StepCount event) async {
    final now = DateTime.now();
    final key = '${now.year}-${now.month}-${now.day}';

    var baseline = await local.getPedometerBaseline(key);
    if (baseline == null) {
      baseline = event.steps;
      await local.savePedometerBaseline(key, baseline);
    }

    return (event.steps - baseline).clamp(0, 1000000);
  }

  @override
  Stream<int> get dailyStepsStream => _stream;
}
