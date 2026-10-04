import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_data_source.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../datasources/pedometer_data_source.dart';
import '../models/dashboard_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remote;
  final DashboardLocalDataSource local;
  final PedometerDataSource pedometer;

  const DashboardRepositoryImpl({
    required this.remote,
    required this.local,
    required this.pedometer,
  });

@override
Future<DashboardData> getDashboard() async {
  final cached =
      await local.getCachedDashboard();

  try {
    final steps = cached?.steps ?? 0;

    final calories =
        await remote.fetchMockCalories(steps);

    final model = DashboardModel(
      steps: steps,
      calories: calories,
      totalSleepMinutes:
          cached?.totalSleepMinutes ?? 0,
      date: DateTime.now().toString(),
    );

    await local.cacheDashboard(model);

    return model.toEntity();
  } catch (_) {
    if (cached != null) {
      return cached.toEntity(
        isOffline: true,
      );
    }

    // First launch with no cache.
    // Still return usable dashboard data.
    final model = DashboardModel(
      steps: 0,
      calories: 0,
      totalSleepMinutes: 0,
      date: DateTime.now().toString(),
    );

    return model.toEntity(
      isOffline: true,
    );
  }
}
  @override
  Stream<int> watchDailySteps() => pedometer.watchDailySteps();

  @override
  Future<void> updateCachedSleep(int totalSleepMinutes) async {
    final cached = await local.getCachedDashboard();
    if (cached == null) return;
    await local.cacheDashboard(
      DashboardModel(
        steps: cached.steps,
        calories: cached.calories,
        totalSleepMinutes: totalSleepMinutes,
        date: cached.date,
      ),
    );
  }
}
