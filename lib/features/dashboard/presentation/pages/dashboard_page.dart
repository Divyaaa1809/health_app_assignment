import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/notification_service.dart';
import '../../../sleep/presentation/bloc/sleep_bloc.dart';
import '../../../sleep/presentation/bloc/sleep_event.dart';
import '../../../sleep/presentation/pages/sleep_details_page.dart';
import '../../../sleep/presentation/pages/sleep_log_page.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/metric_card.dart';

class DashboardPage extends StatelessWidget {
  final NotificationService notifications;

  const DashboardPage({
    super.key,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Health reminder',
            onPressed: notifications.showHealthReminder,
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<DashboardBloc>().add(
                      const DashboardRefreshed(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is! DashboardLoaded) {
            return const SizedBox.shrink();
          }

          final data = state.data;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(
                const DashboardRefreshed(),
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  DateFormat('EEEE, dd MMMM yyyy').format(data.date),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                if (data.isOffline)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.cloud_off),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Offline mode: showing cached data.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                MetricCard(
                  title: 'Steps',
                  value: '${data.steps}',
                  unit: 'steps today',
                  icon: Icons.directions_walk,
                ),
                const SizedBox(height: 12),
                MetricCard(
                  title: 'Calories',
                  value: '${data.calories}',
                  unit: 'kcal',
                  icon: Icons.local_fire_department_outlined,
                ),
                const SizedBox(height: 12),
                MetricCard(
                  title: 'Sleep',
                  value: _formatDuration(data.totalSleep),
                  unit: 'total sleep',
                  icon: Icons.bedtime_outlined,
                  onTap: () async {
                    final sleepBloc = context.read<SleepBloc>();
                    sleepBloc.add(const SleepStarted());
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SleepDetailsPage(
                          sleepBloc: sleepBloc,
                        ),
                      ),
                    );
                    if (context.mounted) {
                      context.read<DashboardBloc>().add(
                        const DashboardRefreshed(),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SleepLogPage(
                          sleepBloc: context.read<SleepBloc>(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Log / Edit Sleep'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
