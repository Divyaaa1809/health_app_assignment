import 'package:equatable/equatable.dart';

class DashboardData extends Equatable {
  final int steps;
  final int calories;
  final Duration totalSleep;
  final DateTime date;
  final bool isOffline;

  const DashboardData({
    required this.steps,
    required this.calories,
    required this.totalSleep,
    required this.date,
    this.isOffline = false,
  });

  DashboardData copyWith({
    int? steps,
    int? calories,
    Duration? totalSleep,
    DateTime? date,
    bool? isOffline,
  }) {
    return DashboardData(
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      totalSleep: totalSleep ?? this.totalSleep,
      date: date ?? this.date,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [steps, calories, totalSleep, date, isOffline];
}
