import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/sleep_bloc.dart';
import '../bloc/sleep_state.dart';
import '../widgets/sleep_metric_tile.dart';
import 'sleep_log_page.dart';

class SleepDetailsPage extends StatelessWidget {
  final SleepBloc sleepBloc;

  const SleepDetailsPage({
    super.key,
    required this.sleepBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sleepBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Sleep Details')),
        body: BlocBuilder<SleepBloc, SleepState>(
          builder: (context, state) {
            if (state is SleepLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SleepError) {
              return Center(child: Text(state.message));
            }

            if (state is! SleepLoaded || state.sleep == null) {
              return Center(
                child: FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SleepLogPage(sleepBloc: sleepBloc),
                    ),
                  ),
                  child: const Text('Log Sleep'),
                ),
              );
            }

            final sleep = state.sleep!;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${DateFormat('hh:mm a').format(sleep.startTime)} - '
                  '${DateFormat('hh:mm a').format(sleep.endTime)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SleepMetricTile(
                  title: 'Total Sleep',
                  value: _format(sleep.totalSleep),
                  description: 'Sleep End - Sleep Start - Awake Time',
                ),
                SleepMetricTile(
                  title: 'Deep Sleep',
                  value: _format(sleep.deepSleep),
                  description: 'Deep Sleep End Time - Deep Sleep Start Time',
                ),
                SleepMetricTile(
                  title: 'REM Sleep',
                  value: _format(sleep.remSleep),
                  description: 'REM Sleep End Time - REM Sleep Start Time',
                ),
                SleepMetricTile(
                  title: 'Light Sleep',
                  value: _format(sleep.lightSleep),
                  description: 'Light Sleep End Time - Light Sleep Start Time',
                ),
                SleepMetricTile(
                  title: 'Awake Time',
                  value: _format(sleep.awakeTime),
                  description: 'Sum of all awake periods during the session',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SleepLogPage(sleepBloc: sleepBloc),
                    ),
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Sleep'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _format(Duration duration) {
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }
}
