import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_sleep.dart';
import '../../domain/usecases/save_sleep.dart';
import 'sleep_event.dart';
import 'sleep_state.dart';

class SleepBloc extends Bloc<SleepEvent, SleepState> {
  final GetSleep getSleep;
  final SaveSleep saveSleep;

  SleepBloc({
    required this.getSleep,
    required this.saveSleep,
  }) : super(SleepInitial()) {
    on<SleepStarted>(_onStarted);
    on<SleepSaved>(_onSaved);
  }

  Future<void> _onStarted(
    SleepStarted event,
    Emitter<SleepState> emit,
  ) async {
    emit(SleepLoading());
    try {
      final sleep = await getSleep();
      emit(SleepLoaded(sleep));
    } catch (_) {
      emit(const SleepError('Unable to load sleep data.'));
    }
  }

  Future<void> _onSaved(
    SleepSaved event,
    Emitter<SleepState> emit,
  ) async {
    emit(SleepSaving(event.sleep));
    try {
      await saveSleep(event.sleep);
      emit(SleepLoaded(event.sleep));
    } catch (_) {
      emit(const SleepError('Unable to save sleep data.'));
    }
  }
}
