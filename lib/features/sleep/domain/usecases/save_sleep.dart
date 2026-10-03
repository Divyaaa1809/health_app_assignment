import '../entities/sleep_data.dart';
import '../repositories/sleep_repository.dart';

class SaveSleep {
  final SleepRepository repository;
  const SaveSleep(this.repository);

  Future<void> call(SleepData sleep) => repository.saveSleep(sleep);
}
