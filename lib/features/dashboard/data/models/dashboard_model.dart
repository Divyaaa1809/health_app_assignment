import '../../domain/entities/dashboard_data.dart';

class DashboardModel {
  final int steps;
  final int calories;
  final int totalSleepMinutes;
  final DateTime date;

  const DashboardModel({
    required this.steps,
    required this.calories,
    required this.totalSleepMinutes,
    required this.date,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      steps: (json['steps'] as num).toInt(),
      calories: (json['calories'] as num).toInt(),
      totalSleepMinutes: (json['totalSleepMinutes'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'steps': steps,
        'calories': calories,
        'totalSleepMinutes': totalSleepMinutes,
        'date': date.toIso8601String(),
      };

  DashboardData toEntity({bool isOffline = false}) => DashboardData(
        steps: steps,
        calories: calories,
        totalSleep: Duration(minutes: totalSleepMinutes),
        date: date,
        isOffline: isOffline,
      );
}
