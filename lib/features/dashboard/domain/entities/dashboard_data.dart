import 'package:equatable/equatable.dart';

class DashboardData extends Equatable {
  final int steps;
  final int calories;
  final int totalSleepMinutes;
  final DateTime date;
  final bool isOffline;

  const DashboardData({
    required this.steps,
    required this.calories,
    required this.totalSleepMinutes,
    required this.date,
    this.isOffline = false,
  });

  DashboardData copyWith({
    int? steps,
    int? calories,
    int? totalSleepMinutes,
    DateTime? date,
    bool? isOffline,
  }) {
    return DashboardData(
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      totalSleepMinutes: totalSleepMinutes ?? this.totalSleepMinutes,
      date: date ?? this.date,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
        steps,
        calories,
        totalSleepMinutes,
        date,
        isOffline,
      ];
}
