class Workout {
  final String id;
  final String name;
  final String description;
  final String difficulty;
  final int xpReward;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.xpReward,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      difficulty: json['difficulty'],
      xpReward: json['xpReward'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'difficulty': difficulty,
    'xpReward': xpReward,
  };
} 