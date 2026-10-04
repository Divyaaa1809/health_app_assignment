import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/sleep_model.dart';

abstract class SleepLocalDataSource {
  Future<SleepModel?> getSleep();
  Future<void> saveSleep(SleepModel model);
}

class HiveSleepLocalDataSource implements SleepLocalDataSource {
  final Box<dynamic> box;

  const HiveSleepLocalDataSource(this.box);

  @override
  Future<SleepModel?> getSleep() async {
    final value = box.get(AppConstants.sleepCacheKey);
    if (value == null) return null;
    return SleepModel.fromJson(
      jsonDecode(value as String) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> saveSleep(SleepModel model) async {
    await box.put(
      AppConstants.sleepCacheKey,
      jsonEncode(model.toJson()),
    );
  }
}
