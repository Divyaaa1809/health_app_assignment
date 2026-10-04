import 'package:flutter/material.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_event.dart';
import '../../domain/entities/sleep_data.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/sleep_bloc.dart';
import '../bloc/sleep_event.dart';

class SleepLogPage extends StatefulWidget {
  const SleepLogPage({super.key});

  @override
  State<SleepLogPage> createState() => _SleepLogPageState();
}

class _SleepLogPageState extends State<SleepLogPage> {
  TimeOfDay? sleepStart;
  TimeOfDay? sleepEnd;

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: sleepStart ?? const TimeOfDay(hour: 22, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        sleepStart = time;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: sleepEnd ?? const TimeOfDay(hour: 6, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        sleepEnd = time;
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) {
      return '--:--';
    }

    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Sleep')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _TimeCard(
              title: 'Sleep Start',
              time: _formatTime(sleepStart),
              onTap: _selectStartTime,
            ),

            const SizedBox(height: 16),

            _TimeCard(
              title: 'Sleep End',
              time: _formatTime(sleepEnd),
              onTap: _selectEndTime,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveSleep,
                child: const Text('Save Sleep'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSleep() async {
    if (sleepStart == null || sleepEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select sleep start and end time')),
      );
      return;
    }

    final now = DateTime.now();

    final start = DateTime(
      now.year,
      now.month,
      now.day,
      sleepStart!.hour,
      sleepStart!.minute,
    );

    var end = DateTime(
      now.year,
      now.month,
      now.day,
      sleepEnd!.hour,
      sleepEnd!.minute,
    );

    // Handles overnight sleep.
    if (!end.isAfter(start)) {
      end = end.add(const Duration(days: 1));
    }

    final totalMinutes = end.difference(start).inMinutes;

    // Assignment assumption:
    // Deep = 25%
    // REM = 20%
    // Light = remaining 55%

    final deepMinutes = (totalMinutes * 0.25).round();

    final remMinutes = (totalMinutes * 0.20).round();

    final lightMinutes = totalMinutes - deepMinutes - remMinutes;

    final deepStart = start;

    final deepEnd = deepStart.add(Duration(minutes: deepMinutes));

    final remStart = deepEnd;

    final remEnd = remStart.add(Duration(minutes: remMinutes));

    final lightStart = remEnd;

    final lightEnd = lightStart.add(Duration(minutes: lightMinutes));

    final sleepData = SleepData(
      sleepStart: start,
      sleepEnd: end,
      deepSleep: SleepInterval(start: deepStart, end: deepEnd),
      remSleep: SleepInterval(start: remStart, end: remEnd),
      lightSleep: SleepInterval(start: lightStart, end: lightEnd),
      awakePeriods: const [],
    );
    if (!sleepData.isBalanced) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid sleep calculation')),
      );
      return;
    }

    // Send data to BLoC.
    // BLoC → SaveSleep → Repository → Hive
    context.read<SleepBloc>().add(SleepSaved(sleepData));

    context.read<DashboardBloc>().add(
      DashboardSleepChanged(sleepData.totalSleep.inMinutes),
    );

    if (!mounted) return;

    Navigator.pop(context, sleepData);
  }
}

class _TimeCard extends StatelessWidget {
  final String title;
  final String time;
  final VoidCallback onTap;

  const _TimeCard({
    required this.title,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Text(
              time,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(width: 8),

            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
