import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sleep_data.dart';
import '../bloc/sleep_bloc.dart';
import '../bloc/sleep_event.dart';
import '../bloc/sleep_state.dart';

class SleepLogPage extends StatefulWidget {
  final SleepData? initialSleep;

  const SleepLogPage({super.key, this.initialSleep});

  @override
  State<SleepLogPage> createState() => _SleepLogPageState();
}

class _SleepLogPageState extends State<SleepLogPage> {
  TimeOfDay? _sleepStart;
  TimeOfDay? _sleepEnd;
  TimeOfDay? _deepStart;
  TimeOfDay? _deepEnd;
  TimeOfDay? _remStart;
  TimeOfDay? _remEnd;
  TimeOfDay? _lightStart;
  TimeOfDay? _lightEnd;
  final List<_TimeRange> _awakePeriods = [];
  bool _didInitialize = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitialize) return;
    _didInitialize = true;

    final s = widget.initialSleep;
    if (s != null) {
      _sleepStart = TimeOfDay.fromDateTime(s.sleepStart);
      _sleepEnd = TimeOfDay.fromDateTime(s.sleepEnd);
      _deepStart = TimeOfDay.fromDateTime(s.deepSleep.start);
      _deepEnd = TimeOfDay.fromDateTime(s.deepSleep.end);
      _remStart = TimeOfDay.fromDateTime(s.remSleep.start);
      _remEnd = TimeOfDay.fromDateTime(s.remSleep.end);
      _lightStart = TimeOfDay.fromDateTime(s.lightSleep.start);
      _lightEnd = TimeOfDay.fromDateTime(s.lightSleep.end);
      _awakePeriods.addAll(
        s.awakePeriods.map(
          (e) => _TimeRange(
            TimeOfDay.fromDateTime(e.start),
            TimeOfDay.fromDateTime(e.end),
          ),
        ),
      );
    }
  }

  Future<TimeOfDay?> _pick(TimeOfDay? current) {
    return showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
      helpText: 'Select time',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
  }

  Duration _duration(TimeOfDay? start, TimeOfDay? end) {
    if (start == null || end == null) return Duration.zero;
    var startMinutes = start.hour * 60 + start.minute;
    var endMinutes = end.hour * 60 + end.minute;
    if (endMinutes <= startMinutes) endMinutes += 24 * 60;
    return Duration(minutes: endMinutes - startMinutes);
  }

  String _formatDuration(Duration value) {
    final h = value.inHours;
    final m = value.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String _time(TimeOfDay? value) =>
      value == null ? 'Select time' : value.format(context);

  Duration get _awakeDuration => _awakePeriods.fold(
        Duration.zero,
        (sum, e) => sum + _duration(e.start, e.end),
      );

  Duration get _totalSleep {
    final session = _duration(_sleepStart, _sleepEnd);
    final result = session - _awakeDuration;
    return result.isNegative ? Duration.zero : result;
  }

  Duration get _deepDuration => _duration(_deepStart, _deepEnd);
  Duration get _remDuration => _duration(_remStart, _remEnd);
  Duration get _lightDuration => _duration(_lightStart, _lightEnd);

  Duration get _stagedSleep =>
      _deepDuration + _remDuration + _lightDuration;

  bool get _balanced =>
      _sleepStart != null &&
      _sleepEnd != null &&
      _deepStart != null &&
      _deepEnd != null &&
      _remStart != null &&
      _remEnd != null &&
      _lightStart != null &&
      _lightEnd != null &&
      _stagedSleep == _totalSleep;

  DateTime _dateTime(TimeOfDay time, {required DateTime base}) {
    return DateTime(
      base.year,
      base.month,
      base.day,
      time.hour,
      time.minute,
    );
  }

  DateTime _endDateTime(
    TimeOfDay start,
    TimeOfDay end, {
    required DateTime base,
  }) {
    final startDate = _dateTime(start, base: base);
    var endDate = _dateTime(end, base: base);
    if (!endDate.isAfter(startDate)) {
      endDate = endDate.add(const Duration(days: 1));
    }
    return endDate;
  }

  SleepData _buildSleep() {
    final base = DateTime.now();
    final start = _dateTime(_sleepStart!, base: base);
    final end = _endDateTime(_sleepStart!, _sleepEnd!, base: base);

    DateTime rangeStart(TimeOfDay value) => _dateTime(value, base: base);
    DateTime rangeEnd(TimeOfDay start, TimeOfDay end) =>
        _endDateTime(start, end, base: base);

    return SleepData(
      sleepStart: start,
      sleepEnd: end,
      deepSleep: SleepInterval(
        start: rangeStart(_deepStart!),
        end: rangeEnd(_deepStart!, _deepEnd!),
      ),
      remSleep: SleepInterval(
        start: rangeStart(_remStart!),
        end: rangeEnd(_remStart!, _remEnd!),
      ),
      lightSleep: SleepInterval(
        start: rangeStart(_lightStart!),
        end: rangeEnd(_lightStart!, _lightEnd!),
      ),
      awakePeriods: _awakePeriods
          .map(
            (e) => SleepInterval(
              start: rangeStart(e.start ?? _sleepStart!),
              end: rangeEnd(e.start ?? _sleepStart!, e.end ?? _sleepEnd!),
            ),
          )
          .toList(),
    );
  }

  Future<void> _save() async {
    if (!_balanced) return;
    context.read<SleepBloc>().add(SleepSaved(_buildSleep()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SleepBloc, SleepState>(
      listener: (context, state) {
        if (state is SleepSavedState) {
          Navigator.of(context).pop(state.sleep);
        }
        if (state is SleepError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Log sleep')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              'Add sleep data',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose times only. No date selection is required.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Sleep session',
              icon: Icons.bedtime_rounded,
              children: [
                _TimeField(
                  label: 'Sleep start',
                  value: _time(_sleepStart),
                  onTap: () async {
                    final value = await _pick(_sleepStart);
                    if (value != null) setState(() => _sleepStart = value);
                  },
                ),
                const SizedBox(height: 12),
                _TimeField(
                  label: 'Sleep end',
                  value: _time(_sleepEnd),
                  onTap: () async {
                    final value = await _pick(_sleepEnd);
                    if (value != null) setState(() => _sleepEnd = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Sleep stages',
              icon: Icons.auto_awesome_rounded,
              children: [
                _StageRange(
                  title: 'Deep Sleep',
                  duration: _deepDuration,
                  start: _time(_deepStart),
                  end: _time(_deepEnd),
                  color: const Color(0xFF5B5CE2),
                  onStart: () async {
                    final value = await _pick(_deepStart);
                    if (value != null) setState(() => _deepStart = value);
                  },
                  onEnd: () async {
                    final value = await _pick(_deepEnd);
                    if (value != null) setState(() => _deepEnd = value);
                  },
                ),
                _StageRange(
                  title: 'REM Sleep',
                  duration: _remDuration,
                  start: _time(_remStart),
                  end: _time(_remEnd),
                  color: const Color(0xFF9A67EA),
                  onStart: () async {
                    final value = await _pick(_remStart);
                    if (value != null) setState(() => _remStart = value);
                  },
                  onEnd: () async {
                    final value = await _pick(_remEnd);
                    if (value != null) setState(() => _remEnd = value);
                  },
                ),
                _StageRange(
                  title: 'Light Sleep',
                  duration: _lightDuration,
                  start: _time(_lightStart),
                  end: _time(_lightEnd),
                  color: const Color(0xFF4D9DE0),
                  onStart: () async {
                    final value = await _pick(_lightStart);
                    if (value != null) setState(() => _lightStart = value);
                  },
                  onEnd: () async {
                    final value = await _pick(_lightEnd);
                    if (value != null) setState(() => _lightEnd = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Awake periods',
              icon: Icons.wb_sunny_outlined,
              trailing: IconButton(
                onPressed: () => setState(
                  () => _awakePeriods.add(_TimeRange(null, null)),
                ),
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
              children: [
                if (_awakePeriods.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      'No awake periods added. Add one if you woke up during the session.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ...List.generate(_awakePeriods.length, (index) {
                  final range = _awakePeriods[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _awakePeriods.length - 1 ? 0 : 12,
                    ),
                    child: _AwakeRange(
                      index: index + 1,
                      start: _time(range.start),
                      end: _time(range.end),
                      duration: _duration(range.start, range.end),
                      onStart: () async {
                        final value = await _pick(range.start);
                        if (value != null) {
                          setState(() => range.start = value);
                        }
                      },
                      onEnd: () async {
                        final value = await _pick(range.end);
                        if (value != null) {
                          setState(() => range.end = value);
                        }
                      },
                      onDelete: () => setState(
                        () => _awakePeriods.removeAt(index),
                      ),
                    ),
                  );
                }),
                if (_awakePeriods.isNotEmpty) ...[
                  const Divider(height: 24),
                  _SummaryRow(
                    label: 'Awake time',
                    value: _formatDuration(_awakeDuration),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            _BalanceCard(
              totalSession: _duration(_sleepStart, _sleepEnd),
              awake: _awakeDuration,
              totalSleep: _totalSleep,
              stagedSleep: _stagedSleep,
              balanced: _balanced,
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _balanced ? _save : null,
                child: BlocBuilder<SleepBloc, SleepState>(
                  builder: (context, state) {
                    if (state is SleepSaving) {
                      return const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    return const Text('Save sleep');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeRange {
  TimeOfDay? start;
  TimeOfDay? end;
  _TimeRange(this.start, this.end);
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.access_time_rounded),
        ),
        child: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _StageRange extends StatelessWidget {
  final String title;
  final Duration duration;
  final String start;
  final String end;
  final Color color;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  const _StageRange({
    required this.title,
    required this.duration,
    required this.start,
    required this.end,
    required this.color,
    required this.onStart,
    required this.onEnd,
  });

  String _duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                _duration(duration),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniTimeButton(label: 'Start', value: start, onTap: onStart),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniTimeButton(label: 'End', value: end, onTap: onEnd),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AwakeRange extends StatelessWidget {
  final int index;
  final String start;
  final String end;
  final Duration duration;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final VoidCallback onDelete;

  const _AwakeRange({
    required this.index,
    required this.start,
    required this.end,
    required this.duration,
    required this.onStart,
    required this.onEnd,
    required this.onDelete,
  });

  String _duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Awake period $index',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              _duration(duration),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _MiniTimeButton(label: 'Start', value: start, onTap: onStart),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniTimeButton(label: 'End', value: end, onTap: onEnd),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniTimeButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _MiniTimeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final Duration totalSession;
  final Duration awake;
  final Duration totalSleep;
  final Duration stagedSleep;
  final bool balanced;

  const _BalanceCard({
    required this.totalSession,
    required this.awake,
    required this.totalSleep,
    required this.stagedSleep,
    required this.balanced,
  });

  String _duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: balanced
            ? const Color(0xFFEAF8F1)
            : const Color(0xFFFFF5E7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                balanced ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: balanced ? const Color(0xFF29966A) : const Color(0xFFD7891F),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  balanced ? 'Sleep data is balanced' : 'Sleep stages do not match yet',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Sleep session', value: _duration(totalSession)),
          const SizedBox(height: 6),
          _SummaryRow(label: 'Awake time', value: _duration(awake)),
          const SizedBox(height: 6),
          _SummaryRow(label: 'Total sleep', value: _duration(totalSleep)),
          const SizedBox(height: 6),
          _SummaryRow(label: 'Deep + REM + Light', value: _duration(stagedSleep)),
          if (!balanced) ...[
            const SizedBox(height: 10),
            const Text(
              'Adjust the stage times or awake periods until Deep + REM + Light equals Total Sleep.',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
