import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/dashboard_model.dart';

abstract class DashboardLocalDataSource {
  Future<DashboardModel?> getCachedDashboard();
  Future<void> cacheDashboard(DashboardModel model);
  Future<int?> getStepBaseline(String dateKey);
  Future<void> saveStepBaseline(String dateKey, int baseline);
}

class HiveDashboardLocalDataSource implements DashboardLocalDataSource {
  final Box<dynamic> box;

  const HiveDashboardLocalDataSource(this.box);

  @override
  Future<DashboardModel?> getCachedDashboard() async {
    final value = box.get(AppConstants.dashboardCacheKey);
    if (value == null) return null;
    return DashboardModel.fromJson(
      jsonDecode(value as String) as Map<String, dynamic>,
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
  Future<int?> getStepBaseline(String dateKey) async {
    return box.get('${AppConstants.stepBaselinePrefix}$dateKey') as int?;
  }

  @override
  Future<void> saveStepBaseline(String dateKey, int baseline) async {
    await box.put(
      '${AppConstants.stepBaselinePrefix}$dateKey',
      baseline,
    );
  }
}
