import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'features/dashboard/data/datasources/pedometer_data_source.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/usecases/get_dashboard.dart';
import 'features/dashboard/domain/usecases/update_sleep_summary.dart';
import 'features/dashboard/domain/usecases/watch_daily_steps.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/sleep/data/datasources/sleep_local_data_source.dart';
import 'features/sleep/data/repositories/sleep_repository_impl.dart';
import 'features/sleep/domain/usecases/get_sleep.dart';
import 'features/sleep/domain/usecases/save_sleep.dart';
import 'features/sleep/presentation/bloc/sleep_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final healthBox = await Hive.openBox<dynamic>(AppConstants.healthBox);
  final sleepBox = await Hive.openBox<dynamic>(AppConstants.sleepBox);

  final notificationService = NotificationService();
  await notificationService.initialize();

  final dashboardLocal = HiveDashboardLocalDataSource(healthBox);
  final sleepLocal = HiveSleepLocalDataSource(sleepBox);
  final sleepRepository = SleepRepositoryImpl(local: sleepLocal);

  final dashboardRepository = DashboardRepositoryImpl(
    local: dashboardLocal,
    remote: DioMockCaloriesDataSource(Dio()),
    pedometer: DevicePedometerDataSource(local: dashboardLocal),
  );

  final dashboardBloc = DashboardBloc(
    getDashboard: GetDashboard(dashboardRepository),
    watchDailySteps: WatchDailySteps(dashboardRepository),
    updateSleepSummary: UpdateSleepSummary(dashboardRepository),
  );

  final sleepBloc = SleepBloc(
    getSleep: GetSleep(sleepRepository),
    saveSleep: SaveSleep(sleepRepository),
  );

  runApp(
    HealthApp(
      dashboardBloc: dashboardBloc,
      sleepBloc: sleepBloc,
      notifications: notificationService,
    ),
  );
}

class HealthApp extends StatelessWidget {
  final DashboardBloc dashboardBloc;
  final SleepBloc sleepBloc;
  final NotificationService notifications;

  const HealthApp({
    super.key,
    required this.dashboardBloc,
    required this.sleepBloc,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: dashboardBloc),
        BlocProvider.value(value: sleepBloc),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Health Dashboard',
        theme: AppTheme.light(),
        home: DashboardPage(notifications: notifications),
      ),
    );
  }
}
