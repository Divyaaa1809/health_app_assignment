import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/sleep_data_hive_model.dart';

class SleepLocalDataSource {
  static const String sleepKey = 'latestSleep';

  Box<SleepDataHiveModel> get _box {
    return Hive.box<SleepDataHiveModel>(AppConstants.sleepBox);
  }

  Future<void> saveSleep(
    SleepDataHiveModel sleep,
  ) async {
    await _box.put(sleepKey, sleep);
  }

  SleepDataHiveModel? getSleep() {
    return _box.get(sleepKey);
  }
}