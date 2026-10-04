import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dashboard_local_data_source.dart';

abstract class PedometerDataSource {
  Stream<int> watchDailySteps();
}

class DevicePedometerDataSource implements PedometerDataSource {
  final DashboardLocalDataSource local;

  const DevicePedometerDataSource({required this.local});

  @override
  Stream<int> watchDailySteps() async* {
    final permission = await Permission.activityRecognition.request();

    if (!permission.isGranted) {
      return;
    }

    await for (final event in Pedometer.stepCountStream) {
      final now = DateTime.now();

      final dateKey = '${now.year}-${now.month}-${now.day}';

      var baseline = await local.getStepBaseline(dateKey);

      if (baseline == null) {
        baseline = event.steps;

        await local.saveStepBaseline(dateKey, baseline);
      }

      final dailySteps = event.steps - baseline;

      yield dailySteps < 0 ? 0 : dailySteps;
    }
  }
}
