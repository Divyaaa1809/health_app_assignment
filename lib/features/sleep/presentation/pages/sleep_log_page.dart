import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sleep_data.dart';
import '../bloc/sleep_bloc.dart';
import '../bloc/sleep_event.dart';
import '../bloc/sleep_state.dart';

class SleepLogPage extends StatefulWidget {
  final SleepBloc sleepBloc;

  const SleepLogPage({
    super.key,
    required this.sleepBloc,
  });

  @override
  State<SleepLogPage> createState() => _SleepLogPageState();
}

class _SleepLogPageState extends State<SleepLogPage> {
  late DateTime _start;
  late DateTime _end;
  final _deepController = TextEditingController(text: '105');
  final _remController = TextEditingController(text: '92');
  final _lightController = TextEditingController(text: '263');
  final _awakeController = TextEditingController(text: '15');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _end = now;
    _start = now.subtract(const Duration(hours: 8));
  }

  @override
  void dispose() {
    _deepController.dispose();
    _remController.dispose();
    _lightController.dispose();
    _awakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.sleepBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Log Sleep')),
        body: BlocListener<SleepBloc, SleepState>(
          listener: (context, state) {
            if (state is SleepLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sleep saved successfully')),
              );
            }
            if (state is SleepError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DateTimeField(
                label: 'Sleep Start',
                value: _start,
                onChanged: (value) => setState(() => _start = value),
              ),
              const SizedBox(height: 12),
              _DateTimeField(
                label: 'Sleep End',
                value: _end,
                onChanged: (value) => setState(() => _end = value),
              ),
              const SizedBox(height: 20),
              _numberField('Deep Sleep (minutes)', _deepController),
              _numberField('REM Sleep (minutes)', _remController),
              _numberField('Light Sleep (minutes)', _lightController),
              _numberField('Awake Time (minutes)', _awakeController),
              const SizedBox(height: 20),
              BlocBuilder<SleepBloc, SleepState>(
                builder: (context, state) {
                  return FilledButton(
                    onPressed: state is SleepSaving ? null : _save,
                    child: state is SleepSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Sleep'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _save() {
    final sleep = SleepData(
      startTime: _start,
      endTime: _end,
      deepSleep: Duration(minutes: int.tryParse(_deepController.text) ?? 0),
      remSleep: Duration(minutes: int.tryParse(_remController.text) ?? 0),
      lightSleep: Duration(minutes: int.tryParse(_lightController.text) ?? 0),
      awakeTime: Duration(minutes: int.tryParse(_awakeController.text) ?? 0),
    );

    if (sleep.endTime.isBefore(sleep.startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sleep end must be after sleep start.')),
      );
      return;
    }

    context.read<SleepBloc>().add(SleepSaved(sleep));
  }
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const _DateTimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final date = await showDatePicker(
          context: context,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now(),
          initialDate: value,
        );
        if (date == null || !context.mounted) return;

        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value),
        );
        if (time == null) return;

        onChanged(DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${value.day.toString().padLeft(2, '0')}/'
            '${value.month.toString().padLeft(2, '0')}/'
            '${value.year} '
            '${value.hour.toString().padLeft(2, '0')}:'
            '${value.minute.toString().padLeft(2, '0')}',
          ),
        ],
      ),
    );
  }
}
