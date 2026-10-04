import 'package:equatable/equatable.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardStarted extends DashboardEvent {
  const DashboardStarted();
}

class DashboardRefreshed extends DashboardEvent {
  const DashboardRefreshed();
}

class DashboardStepsChanged extends DashboardEvent {
  final int steps;
  const DashboardStepsChanged(this.steps);

  @override
  List<Object?> get props => [steps];
}

class DashboardSleepChanged extends DashboardEvent {
  final int totalSleepMinutes;
  const DashboardSleepChanged(this.totalSleepMinutes);

  @override
  List<Object?> get props => [totalSleepMinutes];
}
