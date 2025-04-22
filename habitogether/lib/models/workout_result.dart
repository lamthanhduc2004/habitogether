class WorkoutResult {
  final int xpGained;
  final int newXP;
  final int newLevel;
  final bool levelUp;

  WorkoutResult({
    required this.xpGained,
    required this.newXP,
    required this.newLevel,
    required this.levelUp,
  });

  factory WorkoutResult.fromJson(Map<String, dynamic> json) {
    return WorkoutResult(
      xpGained: json['xpGained'],
      newXP: json['newXP'],
      newLevel: json['newLevel'],
      levelUp: json['levelUp'],
    );
  }
}
