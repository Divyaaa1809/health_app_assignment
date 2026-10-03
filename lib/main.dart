import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'features/dashboard/data/datasources/pedometer_data_source.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/usecases/get_dashboard.dart';
import 'features/dashboard/domain/usecases/watch_daily_steps.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_event.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/sleep/data/datasources/sleep_local_data_source.dart';
import 'features/sleep/data/repositories/sleep_repository_impl.dart';
import 'features/sleep/domain/usecases/get_sleep.dart';
import 'features/sleep/domain/usecases/save_sleep.dart';
import 'features/sleep/presentation/bloc/sleep_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final box = await Hive.openBox<String>(AppConstants.healthBox);

  final dashboardLocal = HiveDashboardLocalDataSource(box);
  final dashboardRepository = DashboardRepositoryImpl(
    remote: MockDashboardRemoteDataSource(),
    local: dashboardLocal,
    pedometer: DevicePedometerDataSource(dashboardLocal),
  );

  final sleepRepository = SleepRepositoryImpl(
    HiveSleepLocalDataSource(box),
  );

  final notifications = NotificationService();
  await notifications.initialize();

  runApp(
    HealthDashboardApp(
      dashboardRepository: dashboardRepository,
      sleepRepository: sleepRepository,
      notifications: notifications,
    ),
  );
}

class HealthDashboardApp extends StatelessWidget {
  final DashboardRepositoryImpl dashboardRepository;
  final SleepRepositoryImpl sleepRepository;
  final NotificationService notifications;

  const HealthDashboardApp({
    super.key,
    required this.dashboardRepository,
    required this.sleepRepository,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DashboardBloc(
            getDashboard: GetDashboard(dashboardRepository),
            watchDailySteps: WatchDailySteps(dashboardRepository),
          )..add(const DashboardStarted()),
        ),
        BlocProvider(
          create: (_) => SleepBloc(
            getSleep: GetSleep(sleepRepository),
            saveSleep: SaveSleep(sleepRepository),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Health Dashboard',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: DashboardPage(notifications: notifications),
      ),
    );
  }
}
