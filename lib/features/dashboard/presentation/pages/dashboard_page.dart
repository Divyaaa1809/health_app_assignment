import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/notification_service.dart';
import '../../../sleep/domain/entities/sleep_data.dart';
import '../../../sleep/presentation/pages/sleep_details_page.dart';
import '../../../sleep/presentation/pages/sleep_log_page.dart';

import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/metric_card.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<DashboardBloc>().add(const DashboardStarted());
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardInitial || state is DashboardLoading) {
              return const _LoadingView();
            }

            if (state is DashboardError) {
              return _ErrorView(
                message: state.message,
                onRetry: () {
                  context.read<DashboardBloc>().add(const DashboardStarted());
                },
              );
            }

            if (state is DashboardLoaded) {
              return _DashboardContent(
                data: state.data,
                notifications: widget.notifications,
                formatDuration: _formatDuration,
                onRefresh: _refresh,
                onOpenSleepDetails: _openSleepDetails,
                onOpenSleepLog: _openSleepLog,
              );
            }

            return const _LoadingView();
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final dynamic data;
  final NotificationService notifications;

  final String Function(int minutes) formatDuration;

  final Future<void> Function() onRefresh;
  final Future<void> Function() onOpenSleepDetails;
  final Future<void> Function() onOpenSleepLog;

  const _DashboardContent({
    required this.data,
    required this.notifications,
    required this.formatDuration,
    required this.onRefresh,
    required this.onOpenSleepDetails,
    required this.onOpenSleepLog,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, d MMMM').format(data.date);

    final goalPercentage = ((data.steps / 8000) * 100).clamp(0, 100).round();

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          // ------------------------------------------------
          // HEADER
          // ------------------------------------------------
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi 👋',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),

              IconButton.filledTonal(
                onPressed: notifications.showHealthReminder,
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ------------------------------------------------
          // HEALTH SUMMARY
          // ------------------------------------------------
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B5CE2), Color(0xFF7778F2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B5CE2).withValues(alpha: 0.20),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Today's health",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Small steps,\nconsistent habits.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (data.isOffline)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Offline • Cached data',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 58,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------
          // METRIC CARDS
          // ------------------------------------------------
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: .95,
            children: [
              MetricCard(
                title: 'Steps',
                value: NumberFormat('#,###').format(data.steps),
                subtitle: 'Today',
                icon: Icons.directions_walk_rounded,
                iconColor: const Color(0xFFEF8A3A),
              ),

              MetricCard(
                title: 'Calories',
                value: '${data.calories}',
                subtitle: 'kcal',
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFE85D75),
              ),

              MetricCard(
                title: 'Sleep',
                value: formatDuration(data.totalSleepMinutes),
                subtitle: 'Tap to view',
                icon: Icons.nightlight_round,
                iconColor: const Color(0xFF5B5CE2),
                onTap: onOpenSleepDetails,
              ),

              MetricCard(
                title: 'Daily goal',
                value: '$goalPercentage%',
                subtitle: '8,000 steps',
                icon: Icons.flag_rounded,
                iconColor: const Color(0xFF4DAA79),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------
          // SLEEP SECTION
          // ------------------------------------------------
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEBFF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.bedtime_rounded,
                          color: Color(0xFF5B5CE2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sleep tracking',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      TextButton(
                        onPressed: onOpenSleepDetails,
                        child: const Text('View'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    data.totalSleepMinutes > 0
                        ? 'Your latest manual sleep log is saved locally.'
                        : 'Add your sleep times and stages to get started.',
                    style: const TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onOpenSleepLog,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add / Edit Sleep'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------
          // GOAL PROGRESS
          // ------------------------------------------------
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_walk_rounded,
                        color: Color(0xFFEF8A3A),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Daily step goal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '$goalPercentage%',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: (data.steps / 8000).clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFFEDEDF2),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${NumberFormat('#,###').format(data.steps)} / 8,000 steps',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 18),
          Text(
            'Loading your health data...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait while we prepare your dashboard.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64),

            const SizedBox(height: 18),

            Text(
              'Something went wrong',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            Text(message, textAlign: TextAlign.center),

            const SizedBox(height: 20),

            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
