import 'package:dio/dio.dart';
import 'package:health_app_assignment/features/dashboard/data/datasources/dashboard_remote_data_source.dart'
    show DioMockCaloriesDataSource;
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/dashboard/data/datasources/dashboard_local_data_source.dart';
import '../../features/dashboard/data/datasources/pedometer_data_source.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/usecases/get_dashboard.dart';
import '../../features/dashboard/domain/usecases/update_sleep_summary.dart';
import '../../features/dashboard/domain/usecases/watch_daily_steps.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

import '../../features/sleep/data/datasources/sleep_local_data_source.dart';
import '../../features/sleep/data/models/sleep_data_hive_model.dart';
import '../../features/sleep/data/repositories/sleep_repository_impl.dart';
import '../../features/sleep/domain/usecases/get_sleep.dart';
import '../../features/sleep/domain/usecases/save_sleep.dart';
import '../../features/sleep/presentation/bloc/sleep_bloc.dart';

import '../constants/app_constants.dart';
import '../services/notification_service.dart';

class AppDependencies {
  late final DashboardBloc dashboardBloc;
  late final SleepBloc sleepBloc;
  late final NotificationService notificationService;

  Future<void> initialize() async {
    // Hive
    await Hive.initFlutter();

    final healthBox = await Hive.openBox<dynamic>(AppConstants.healthBox);

    Hive.registerAdapter(SleepDataHiveModelAdapter());

    await Hive.openBox<SleepDataHiveModel>(AppConstants.sleepBox);

    // Services
    notificationService = NotificationService();
    notificationService.initializeNotifications();

    // Dashboard dependencies
    final dashboardLocal = HiveDashboardLocalDataSource(healthBox);

    final dashboardRepository = DashboardRepositoryImpl(
      local: dashboardLocal,
      remote: DioMockCaloriesDataSource(Dio()),
      pedometer: DevicePedometerDataSource(local: dashboardLocal),
    );

    dashboardBloc = DashboardBloc(
      getDashboard: GetDashboard(dashboardRepository),
      watchDailySteps: WatchDailySteps(dashboardRepository),
      updateSleepSummary: UpdateSleepSummary(dashboardRepository),
    );

    // Sleep dependencies
    final sleepLocal = SleepLocalDataSource();

    final sleepRepository = SleepRepositoryImpl(localDataSource: sleepLocal);

    sleepBloc = SleepBloc(
      getSleep: GetSleep(sleepRepository),
      saveSleep: SaveSleep(sleepRepository),
    );
  }
}
