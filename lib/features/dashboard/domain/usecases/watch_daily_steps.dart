import '../repositories/dashboard_repository.dart';

class WatchDailySteps {
  final DashboardRepository repository;
  const WatchDailySteps(this.repository);

  Stream<int> call() => repository.watchDailySteps();
}
