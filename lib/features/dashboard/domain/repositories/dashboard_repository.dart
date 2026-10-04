import '../entities/dashboard_data.dart';

abstract class DashboardRepository {
  Future<DashboardData> getDashboard();
  Stream<int> watchDailySteps();
  Future<void> updateCachedSleep(int totalSleepMinutes);
}
