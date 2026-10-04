import '../entities/sleep_data.dart';
import '../repositories/sleep_repository.dart';

class GetSleep {
  final SleepRepository repository;
  const GetSleep(this.repository);

  SleepData? call() => repository.getSleep();
}
