import '../entities/sleep_data.dart';

abstract class SleepRepository {
  Future<void> saveSleep(SleepData sleep);

  SleepData? getSleep();
}