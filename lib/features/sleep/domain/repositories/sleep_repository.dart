import '../entities/sleep_data.dart';

abstract class SleepRepository {
  Future<SleepData?> getSleep();
  Future<void> saveSleep(SleepData sleep);
}
