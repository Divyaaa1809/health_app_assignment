import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_dashboard.dart';
import '../../domain/usecases/watch_daily_steps.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboard getDashboard;
  final WatchDailySteps watchDailySteps;
  StreamSubscription<int>? _stepsSubscription;

  DashboardBloc({
    required this.getDashboard,
    required this.watchDailySteps,
  }) : super(DashboardInitial()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardRefreshed>(_onRefreshed);
    on<DashboardStepsChanged>(_onStepsChanged);
  }

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      final data = await getDashboard();
      emit(DashboardLoaded(data));
      await _listenToSteps();
    } catch (_) {
      emit(const DashboardError(
        'Unable to load health data. Please retry.',
      ));
    }
  }

  Future<void> _onRefreshed(
    DashboardRefreshed event,
    Emitter<DashboardState> emit,
  ) async {
    await _onStarted(const DashboardStarted(), emit);
  }

  Future<void> _listenToSteps() async {
    await _stepsSubscription?.cancel();
    _stepsSubscription = watchDailySteps().listen(
      (steps) => add(DashboardStepsChanged(steps)),
      onError: (_) {},
    );
  }

  void _onStepsChanged(
    DashboardStepsChanged event,
    Emitter<DashboardState> emit,
  ) {
    final current = state;
    if (current is DashboardLoaded) {
      emit(DashboardLoaded(
        current.data.copyWith(steps: event.steps),
      ));
    }
  }

  @override
  Future<void> close() async {
    await _stepsSubscription?.cancel();
    return super.close();
  }
}
