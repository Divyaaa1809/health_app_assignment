import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/services/notification_service.dart';
import '../../../sleep/domain/entities/sleep_data.dart';
import '../../../sleep/presentation/pages/sleep_details_page.dart';
import '../../../sleep/presentation/pages/sleep_log_page.dart';

import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_content.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

class DashboardPage extends StatefulWidget {
  final NotificationService notifications;

  const DashboardPage({super.key, required this.notifications});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      context.read<DashboardBloc>().add(const DashboardStarted());

      await _requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardInitial || state is DashboardLoading) {
              return const LoadingView();
            }

            if (state is DashboardError) {
              return ErrorView(
                message: state.message,
                onRetry: () {
                  context.read<DashboardBloc>().add(const DashboardStarted());
                },
              );
            }

            if (state is DashboardLoaded) {
              return DashboardContent(
                data: state.data,
                notifications: widget.notifications,
                formatDuration: _formatDuration,
                onRefresh: _refresh,
                onOpenSleepDetails: _openSleepDetails,
                onOpenSleepLog: _openSleepLog,
              );
            }

            return const LoadingView();
          },
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) {
      return '--';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '${remainingMinutes}m';
    }

    if (remainingMinutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${remainingMinutes}m';
  }

  Future<void> _openSleepDetails() async {
    final sleep = await Navigator.push<SleepData?>(
      context,
      MaterialPageRoute(builder: (_) => SleepDetailsPage()),
    );

    if (!mounted || sleep == null) {
      return;
    }

    context.read<DashboardBloc>().add(
      DashboardSleepChanged(sleep.totalSleep.inMinutes),
    );
  }

  Future<void> _openSleepLog() async {
    final sleep = await Navigator.of(
      context,
    ).push<SleepData>(MaterialPageRoute(builder: (_) => SleepLogPage()));

    if (!mounted || sleep == null) {
      return;
    }

    // We only update the existing DashboardLoaded state.
    //
    // We DO NOT call DashboardStarted or DashboardRefreshed.
    context.read<DashboardBloc>().add(
      DashboardSleepChanged(sleep.totalSleep.inMinutes),
    );
  }

  Future<void> _refresh() async {
    final bloc = context.read<DashboardBloc>();

    bloc.add(const DashboardRefreshed());

    await bloc.stream.firstWhere(
      (state) => state is DashboardLoaded || state is DashboardError,
    );
  }

  Future<void> _requestPermissions() async {
    await Permission.activityRecognition.request();

    await Permission.notification.request();
  }
}
