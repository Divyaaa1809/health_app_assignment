import '../entities/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboard {
  final DashboardRepository repository;
  const GetDashboard(this.repository);

  Future<DashboardData> call() => repository.getDashboard();
}
