import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/dashboard_model.dart';

abstract class DashboardLocalDataSource {
  Future<DashboardModel?> getCachedDashboard();
  Future<void> cacheDashboard(DashboardModel model);
  Future<int?> getPedometerBaseline(String dateKey);
  Future<void> savePedometerBaseline(String dateKey, int baseline);
}

class HiveDashboardLocalDataSource implements DashboardLocalDataSource {
  final Box<String> box;

  const HiveDashboardLocalDataSource(this.box);

  @override
  Future<DashboardModel?> getCachedDashboard() async {
    final raw = box.get(AppConstants.dashboardCacheKey);
    if (raw == null) return null;
    return DashboardModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> cacheDashboard(DashboardModel model) async {
    await box.put(
      AppConstants.dashboardCacheKey,
      jsonEncode(model.toJson()),
    );
  }

  @override
  Future<int?> getPedometerBaseline(String dateKey) async {
    final value = box.get(
      '${AppConstants.pedometerBaselinePrefix}$dateKey',
    );
    return value == null ? null : int.tryParse(value);
  }

  @override
  Future<void> savePedometerBaseline(
    String dateKey,
    int baseline,
  ) async {
    await box.put(
      '${AppConstants.pedometerBaselinePrefix}$dateKey',
      baseline.toString(),
    );
  }
}
