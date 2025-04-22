import 'workout.dart';

class DailyWorkout {
  final String id;
  final Workout workout;
  final DateTime date;
  final bool completed;

  DailyWorkout({
    required this.id,
    required this.workout,
    required this.date,
    required this.completed,
  });

  factory DailyWorkout.fromJson(Map<String, dynamic> json) {
    return DailyWorkout(
      id: json['_id'],
      workout: Workout.fromJson(json['workout']),
      date: DateTime.parse(json['date']),
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'workout': workout.toJson(),
    'date': date.toIso8601String(),
    'completed': completed,
  };
}
