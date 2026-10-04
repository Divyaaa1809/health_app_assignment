import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_app_assignment/features/dashboard/presentation/pages/dashboard_page.dart';
import 'core/di/app_dependencies.dart';
import 'core/navigator/app_navigator.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/sleep/presentation/bloc/sleep_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = AppDependencies();

  await dependencies.initialize();

  runApp(
    HealthApp(
      dashboardBloc: dependencies.dashboardBloc,
      sleepBloc: dependencies.sleepBloc,
      notifications: dependencies.notificationService,
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
        navigatorKey: AppNavigator.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Health Dashboard',
        theme: AppTheme.light(),
        home: DashboardPage(notifications: notifications),
      ),
    );
  }
}
