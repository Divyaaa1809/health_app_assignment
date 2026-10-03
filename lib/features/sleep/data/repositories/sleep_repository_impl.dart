import '../../domain/entities/sleep_data.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../datasources/sleep_local_data_source.dart';
import '../models/sleep_model.dart';

class SleepRepositoryImpl implements SleepRepository {
  final SleepLocalDataSource local;

  const SleepRepositoryImpl(this.local);

  @override
  Future<SleepData?> getSleep() async {
    final model = await local.getSleep();
    return model?.toEntity();
  }

  @override
  Future<void> saveSleep(SleepData sleep) {
    return local.saveSleep(SleepModel.fromEntity(sleep));
  }
}
