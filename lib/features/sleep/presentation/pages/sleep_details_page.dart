import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/sleep_data.dart';
import '../bloc/sleep_bloc.dart';
import '../bloc/sleep_event.dart';
import '../bloc/sleep_state.dart';
import '../widgets/sleep_metric_tile.dart';
import 'sleep_log_page.dart';

class SleepDetailsPage extends StatefulWidget {
  const SleepDetailsPage({super.key});

  @override
  State<SleepDetailsPage> createState() => _SleepDetailsPageState();
}

class _SleepDetailsPageState extends State<SleepDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SleepBloc>().add(const SleepStarted());
    });
  }


  String _duration(Duration d) {
    if (d.isNegative) return '0m';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String _time(DateTime value) => DateFormat('h:mm a').format(value);

  Future<void> _edit(BuildContext context, SleepData? current) async {
    await Navigator.of(context).push<SleepData>(
      MaterialPageRoute(
        builder: (_) => SleepLogPage(initialSleep: current),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep details')),
      body: BlocBuilder<SleepBloc, SleepState>(
        builder: (context, state) {
          if (state is SleepLoading || state is SleepInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SleepError) {
            return Center(child: Text(state.message));
          }

          final sleep = state is SleepSavedState
              ? state.sleep
              : state is SleepLoaded
                  ? state.sleep
                  : null;

          if (sleep == null) {
            return _EmptySleep(onAdd: () => _edit(context, null));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF292A68), Color(0xFF5B5CE2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.nightlight_round,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Total sleep',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _duration(sleep.totalSleep),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_time(sleep.sleepStart)}  →  ${_time(sleep.sleepEnd)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sleep stages',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              SleepMetricTile(
                title: 'Deep Sleep',
                value: _duration(sleep.deepSleep.duration),
                icon: Icons.bedtime_rounded,
                color: const Color(0xFF5B5CE2),
              ),
              const SizedBox(height: 10),
              SleepMetricTile(
                title: 'REM Sleep',
                value: _duration(sleep.remSleep.duration),
                icon: Icons.auto_awesome_rounded,
                color: const Color(0xFF9A67EA),
              ),
              const SizedBox(height: 10),
              SleepMetricTile(
                title: 'Light Sleep',
                value: _duration(sleep.lightSleep.duration),
                icon: Icons.cloud_rounded,
                color: const Color(0xFF4D9DE0),
              ),
              const SizedBox(height: 10),
              SleepMetricTile(
                title: 'Awake Time',
                value: _duration(sleep.awakeTime),
                icon: Icons.wb_sunny_outlined,
                color: const Color(0xFFEF9B3D),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How it is calculated',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Total Sleep = Sleep End − Sleep Start − Awake Time',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Deep + REM + Light = Total Sleep',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => _edit(context, sleep),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit sleep'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptySleep extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptySleep({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bedtime_outlined, size: 72),
            const SizedBox(height: 18),
            const Text(
              'No sleep log yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your sleep session and sleep stages manually.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onAdd, child: const Text('Add sleep')),
          ],
        ),
      ),
    );
  }
}
