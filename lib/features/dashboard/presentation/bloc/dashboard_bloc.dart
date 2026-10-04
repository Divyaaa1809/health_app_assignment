import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_dashboard.dart';
import '../../domain/usecases/watch_daily_steps.dart';
import '../../domain/usecases/update_sleep_summary.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboard getDashboard;
  final WatchDailySteps watchDailySteps;
  final UpdateSleepSummary updateSleepSummary;

  StreamSubscription<int>? _stepsSubscription;

  DashboardBloc({
    required this.getDashboard,
    required this.watchDailySteps,
    required this.updateSleepSummary,
  }) : super(DashboardInitial()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardRefreshed>(_onRefreshed);
    on<DashboardStepsChanged>(_onStepsChanged);
    on<DashboardSleepChanged>(_onSleepChanged);
  }

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    // If dashboard is already loaded, don't show loader again.
    if (state is DashboardLoaded) {
      return;
    }

    await _loadDashboard(emit);
  }

  Future<void> _onRefreshed(
    DashboardRefreshed event,
    Emitter<DashboardState> emit,
  ) async {
    // Refresh is the only operation that intentionally
    // reloads the dashboard.
    await _loadDashboard(emit);
  }

  Future<void> _loadDashboard(Emitter<DashboardState> emit) async {
    emit(DashboardLoading());

    try {
      final data = await getDashboard();

      // First show dashboard.
      emit(DashboardLoaded(data));

      // Start pedometer AFTER dashboard is visible.
      _startSteps();
    } catch (error, stackTrace) {
      debugPrint('Dashboard loading error: $error');
      debugPrint('stackTrace: $stackTrace');

      emit(DashboardError('Unable to load health data.\n$error'));
    }
  }

  void _startSteps() {
    _stepsSubscription?.cancel();

    _stepsSubscription = watchDailySteps().listen(
      (steps) {
        add(DashboardStepsChanged(steps));
      },
      onError: (error) {
        debugPrint('Pedometer error: $error');
      },
    );
  }

  void _onStepsChanged(
    DashboardStepsChanged event,
    Emitter<DashboardState> emit,
  ) {
    final currentState = state;

    if (currentState is DashboardLoaded) {
      final updatedData = currentState.data.copyWith(steps: event.steps);

      emit(DashboardLoaded(updatedData));
    }
  }

  Future<void> _onSleepChanged(
    DashboardSleepChanged event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;

    if (currentState is! DashboardLoaded) {
      return;
    }

    final updatedData = currentState.data.copyWith(
      totalSleepMinutes: event.totalSleepMinutes,
      isOffline: false,
    );

    // Do NOT emit DashboardLoading here.
    //
    // Therefore, when we return from Sleep screen,
    // the dashboard remains visible.
    emit(DashboardLoaded(updatedData));

    try {
      await updateSleepSummary(event.totalSleepMinutes);
    } catch (error) {
      debugPrint('Unable to save sleep summary: $error');
    }
  }

  @override
  Future<void> close() async {
    await _stepsSubscription?.cancel();

    return super.close();
  }
}
