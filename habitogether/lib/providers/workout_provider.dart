import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../models/daily_workout.dart';
import '../models/workout_result.dart';
import '../services/workout_service.dart';

class WorkoutProvider with ChangeNotifier {
  final WorkoutService _workoutService;

  List<Workout> _workouts = [];
  List<DailyWorkout> _dailyWorkouts = [];
  int _completedCount = 0;

  WorkoutProvider({required String token})
    : _workoutService = WorkoutService(token: token);

  // Getters
  List<Workout> get workouts => _workouts;
  List<DailyWorkout> get dailyWorkouts => _dailyWorkouts;
  int get completedCount => _completedCount;

  // Lấy danh sách tất cả workout
  Future<void> fetchWorkouts() async {
    try {
      _workouts = await _workoutService.getAllWorkouts();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Lấy danh sách daily workout
  Future<void> fetchDailyWorkouts() async {
    try {
      final result = await _workoutService.getDailyWorkouts();
      _dailyWorkouts = result['dailyWorkouts'];
      _completedCount = result['completedCount'];
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Thêm workout vào danh sách hàng ngày
  Future<DailyWorkout> addToDailyWorkout(String workoutId) async {
    try {
      final dailyWorkout = await _workoutService.addToDailyWorkout(workoutId);
      _dailyWorkouts.add(dailyWorkout);
      notifyListeners();
      return dailyWorkout;
    } catch (e) {
      rethrow;
    }
  }

  // Hoàn thành workout
  Future<WorkoutResult> completeWorkout(String dailyWorkoutId) async {
    try {
      final result = await _workoutService.completeWorkout(dailyWorkoutId);
      // Xóa workout đã hoàn thành khỏi danh sách
      _dailyWorkouts.removeWhere((dw) => dw.id == dailyWorkoutId);
      _completedCount++;
      notifyListeners();
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
