import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout.dart';
import '../models/daily_workout.dart';
import '../models/workout_result.dart';
import '../utils/constants.dart';
import '../utils/config.dart';

class WorkoutService {
  final String token;
  final bool _useLocalData = true; // Sử dụng dữ liệu mẫu thay vì API
  static String get _apiUrl => AppConfig.getApiUrl();
  
  // Tạo dữ liệu mẫu cục bộ
  final List<Map<String, dynamic>> _sampleWorkouts = [
    {
      '_id': '1',
      'name': 'Chạy bộ 30 phút',
      'description': 'Chạy bộ nhẹ nhàng trong 30 phút để tăng sức bền',
      'difficulty': 'easy',
      'xpReward': 25,
    },
    {
      '_id': '2',
      'name': 'Plank 5 phút',
      'description': 'Giữ tư thế plank trong 5 phút để tăng cường cơ bụng',
      'difficulty': 'easy',
      'xpReward': 25,
    },
    {
      '_id': '3',
      'name': '100 cái hít đất',
      'description': 'Thực hiện 100 cái hít đất để tăng cường cơ ngực và tay',
      'difficulty': 'easy',
      'xpReward': 25,
    },
    {
      '_id': '4',
      'name': 'Yoga 20 phút',
      'description': 'Thực hiện các bài tập yoga cơ bản trong 20 phút',
      'difficulty': 'easy',
      'xpReward': 25,
    },
    {
      '_id': '5',
      'name': '50 cái gập bụng',
      'description': 'Thực hiện 50 cái gập bụng để tăng cường cơ bụng',
      'difficulty': 'easy',
      'xpReward': 25,
    },
    {
      '_id': '6',
      'name': 'Đạp xe 1 giờ',
      'description': 'Đạp xe trong 1 giờ để tăng sức bền và đốt cháy calo',
      'difficulty': 'easy',
      'xpReward': 25,
    },
    {
      '_id': '7',
      'name': 'Học từ mới tiếng Anh',
      'description': 'Học và ghi nhớ 10 từ mới tiếng Anh mỗi ngày',
      'difficulty': 'hard',
      'xpReward': 25,
    },
    {
      '_id': '8',
      'name': 'Học lập trình 1 tiếng',
      'description': 'Dành 1 tiếng để học và thực hành lập trình',
      'difficulty': 'hard',
      'xpReward': 25,
    },
    {
      '_id': '9',
      'name': 'Đọc sách 30 phút',
      'description': 'Đọc sách để phát triển kiến thức và thói quen đọc',
      'difficulty': 'medium',
      'xpReward': 25,
    },
    {
      '_id': '10',
      'name': 'Viết nhật ký',
      'description': 'Viết nhật ký để rèn luyện kỹ năng viết và suy ngẫm',
      'difficulty': 'medium',
      'xpReward': 25,
    },
  ];

  // Tạo danh sách bài tập hàng ngày
  final List<Map<String, dynamic>> _sampleDailyWorkouts = [];

  WorkoutService({required this.token}) {
    // Khởi tạo dữ liệu mẫu cho daily workouts
    if (_sampleDailyWorkouts.isEmpty) {
      _sampleDailyWorkouts.add({
        '_id': 'd1',
        'workout': _sampleWorkouts[0],
        'date': DateTime.now().toIso8601String(),
        'completed': false,
      });

      _sampleDailyWorkouts.add({
        '_id': 'd2',
        'workout': _sampleWorkouts[3],
        'date': DateTime.now().toIso8601String(),
        'completed': false,
      });
    }
  }

  // Lấy danh sách tất cả workout
  Future<List<Workout>> getAllWorkouts() async {
    if (_useLocalData) {
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Giả lập độ trễ mạng
      return _sampleWorkouts.map((json) => Workout.fromJson(json)).toList();
    }

    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/workouts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> workoutsJson = data['data'];
          return workoutsJson.map((json) => Workout.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load workouts');
        }
      } else {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      // Fallback sang dữ liệu mẫu nếu API gặp lỗi
      return _sampleWorkouts.map((json) => Workout.fromJson(json)).toList();
    }
  }

  // Lấy danh sách daily workout
  Future<Map<String, dynamic>> getDailyWorkouts() async {
    if (_useLocalData) {
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Giả lập độ trễ mạng

      final dailyWorkouts =
          _sampleDailyWorkouts
              .map((json) => DailyWorkout.fromJson(json))
              .toList();

      return {
        'dailyWorkouts': dailyWorkouts,
        'completedCount': 0,
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/daily-workouts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final Map<String, dynamic> workoutData = data['data'];
          final List<dynamic> dailyWorkoutsJson = workoutData['dailyWorkouts'];
          return {
            'dailyWorkouts':
                dailyWorkoutsJson
                    .map((json) => DailyWorkout.fromJson(json))
                    .toList(),
            'completedCount': workoutData['completedCount'],
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to load daily workouts');
        }
      } else {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      // Fallback sang dữ liệu mẫu nếu API gặp lỗi
      final dailyWorkouts =
          _sampleDailyWorkouts
              .map((json) => DailyWorkout.fromJson(json))
              .toList();

      return {
        'dailyWorkouts': dailyWorkouts,
        'completedCount': 0,
      };
    }
  }

  // Thêm workout vào danh sách hàng ngày
  Future<DailyWorkout> addToDailyWorkout(String workoutId) async {
    if (_useLocalData) {
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Giả lập độ trễ mạng

      // Tìm workout cần thêm
      final workout = _sampleWorkouts.firstWhere(
        (w) => w['_id'] == workoutId,
        orElse: () => throw Exception('Workout not found'),
      );

      // Tạo daily workout mới
      final newDailyWorkout = {
        '_id': 'd${DateTime.now().millisecondsSinceEpoch}',
        'workout': workout,
        'date': DateTime.now().toIso8601String(),
        'completed': false,
      };

      // Thêm vào danh sách mẫu
      _sampleDailyWorkouts.add(newDailyWorkout);

      return DailyWorkout.fromJson(newDailyWorkout);
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/daily-workouts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'workoutId': workoutId}),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return DailyWorkout.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to add workout');
        }
      } else {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      // Fallback sang local nếu API gặp lỗi
      // Tìm workout cần thêm
      final workout = _sampleWorkouts.firstWhere(
        (w) => w['_id'] == workoutId,
        orElse: () => throw Exception('Workout not found'),
      );

      // Tạo daily workout mới
      final newDailyWorkout = {
        '_id': 'd${DateTime.now().millisecondsSinceEpoch}',
        'workout': workout,
        'date': DateTime.now().toIso8601String(),
        'completed': false,
      };

      // Thêm vào danh sách mẫu
      _sampleDailyWorkouts.add(newDailyWorkout);

      return DailyWorkout.fromJson(newDailyWorkout);
    }
  }

  // Hoàn thành workout
  Future<WorkoutResult> completeWorkout(String dailyWorkoutId) async {
    if (_useLocalData) {
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Giả lập độ trễ mạng

      // Tìm daily workout cần hoàn thành
      final index = _sampleDailyWorkouts.indexWhere(
        (dw) => dw['_id'] == dailyWorkoutId,
      );

      if (index == -1) {
        throw Exception('Daily workout not found');
      }

      // Đánh dấu là đã hoàn thành (dù chúng ta sẽ xóa nó khỏi danh sách sau đó)
      _sampleDailyWorkouts[index]['completed'] = true;

      // Lấy XP từ workout
      final int xpGained =
          _sampleDailyWorkouts[index]['workout']['xpReward'] as int;

      // Giả lập việc tính toán XP và level
      final int newXP = xpGained; // Trong thực tế, cần cộng với XP hiện tại
      final int newLevel = (newXP / xpPerLevel).floor() + 1;
      final bool levelUp = newXP >= xpPerLevel; // Giả lập level up

      // Xóa daily workout khỏi danh sách (điều này sẽ được thực hiện ở WorkoutProvider)

      return WorkoutResult(
        xpGained: xpGained,
        newXP: newXP,
        newLevel: newLevel,
        levelUp: levelUp,
      );
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/complete-workout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'dailyWorkoutId': dailyWorkoutId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return WorkoutResult.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to complete workout');
        }
      } else {
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      // Fallback sang local nếu API gặp lỗi
      // Tìm daily workout cần hoàn thành
      final index = _sampleDailyWorkouts.indexWhere(
        (dw) => dw['_id'] == dailyWorkoutId,
      );

      if (index == -1) {
        throw Exception('Daily workout not found');
      }

      // Đánh dấu là đã hoàn thành
      _sampleDailyWorkouts[index]['completed'] = true;

      // Lấy XP từ workout
      final int xpGained =
          _sampleDailyWorkouts[index]['workout']['xpReward'] as int;

      // Giả lập việc tính toán XP và level
      final int newXP = xpGained;
      final int newLevel = (newXP / xpPerLevel).floor() + 1;
      final bool levelUp = newXP >= xpPerLevel;

      return WorkoutResult(
        xpGained: xpGained,
        newXP: newXP,
        newLevel: newLevel,
        levelUp: levelUp,
      );
    }
  }
}
