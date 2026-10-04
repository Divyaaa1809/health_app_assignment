import '../../domain/entities/dashboard_data.dart';

class DashboardModel {
  final int steps;
  final int calories;
  final int totalSleepMinutes;
  final String date;

  const DashboardModel({
    required this.steps,
    required this.calories,
    required this.totalSleepMinutes,
    required this.date,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      steps: json['steps'] as int,
      calories: json['calories'] as int,
      totalSleepMinutes: json['totalSleepMinutes'] as int,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'steps': steps,
        'calories': calories,
        'totalSleepMinutes': totalSleepMinutes,
        'date': date,
      };

  DashboardData toEntity({bool isOffline = false}) {
    return DashboardData(
      steps: steps,
      calories: calories,
      totalSleepMinutes: totalSleepMinutes,
      date: DateTime.parse(date),
      isOffline: isOffline,
    );
  }
}
