import '../models/dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardModel> fetchDashboard(int steps);
}

class MockDashboardRemoteDataSource implements DashboardRemoteDataSource {
  @override
  Future<DashboardModel> fetchDashboard(int steps) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    // Mock REST response. Replace this data source with Dio/API implementation
    // without changing the domain or presentation layers.
    final response = <String, dynamic>{
      'steps': steps,
      'calories': 400 + ((steps / 1000).round() * 35),
      'totalSleepMinutes': 465,
      'date': DateTime.now().toIso8601String(),
    };

    return DashboardModel.fromJson(response);
  }
}
