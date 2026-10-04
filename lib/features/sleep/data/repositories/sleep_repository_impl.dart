import '../../domain/entities/sleep_data.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../datasources/sleep_local_data_source.dart';
import '../models/sleep_data_hive_model.dart';

class SleepRepositoryImpl implements SleepRepository {
  final SleepLocalDataSource localDataSource;

  SleepRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveSleep(SleepData sleep) async {
    final model = SleepDataHiveModel.fromEntity(sleep);

    await localDataSource.saveSleep(model);
  }

  @override
  SleepData? getSleep() {
    final model = localDataSource.getSleep();

    return model?.toEntity();
  }
}
