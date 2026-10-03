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
    final cached = await local.getCachedDashboard();
    final steps = await _getSteps(cached?.steps ?? 0);

    try {
      final remoteData = await remote.fetchDashboard(steps);
      await local.cacheDashboard(remoteData);
      return remoteData.toEntity();
    } catch (_) {
      if (cached != null) {
        return DashboardModel(
          steps: steps,
          calories: cached.calories,
          totalSleepMinutes: cached.totalSleepMinutes,
          date: cached.date,
        ).toEntity(isOffline: true);
      }
      rethrow;
    }
  }

  Future<int> _getSteps(int fallback) async {
    try {
      return await pedometer.dailyStepsStream.first.timeout(
        const Duration(seconds: 3),
        onTimeout: () => fallback,
      );
    } catch (_) {
      return fallback;
    }
  }

  @override
  Stream<int> watchDailySteps() => pedometer.dailyStepsStream;
}
