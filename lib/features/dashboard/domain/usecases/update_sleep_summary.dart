import '../repositories/dashboard_repository.dart';

class UpdateSleepSummary {
  final DashboardRepository repository;
  const UpdateSleepSummary(this.repository);

  Future<void> call(int totalSleepMinutes) =>
      repository.updateCachedSleep(totalSleepMinutes);
}
