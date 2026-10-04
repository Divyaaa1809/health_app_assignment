import 'package:dio/dio.dart';

abstract class DashboardRemoteDataSource {
  Future<int> fetchMockCalories(int steps);
}

class DioMockCaloriesDataSource implements DashboardRemoteDataSource {
  final Dio dio;

  const DioMockCaloriesDataSource(this.dio);

  @override
  Future<int> fetchMockCalories(int steps) async {
    try {
      final response = await dio.get(
        'https://jsonplaceholder.typicode.com/todos/1',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final data = Map<String, dynamic>.from(response.data as Map);

      final id = (data['id'] as num).toInt();

      return 300 + (steps ~/ 1000) * 40 + id * 10;
    } on DioException {
      // Mock fallback.
      // The dashboard can still work if the mock server
      // is unavailable.
      return 300 + (steps ~/ 1000) * 40;
    } catch (_) {
      return 300 + (steps ~/ 1000) * 40;
    }
  }
}
