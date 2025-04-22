import 'package:flutter/material.dart';

enum PetType { dragon, fox, axolotl }

extension PetTypeExtension on PetType {
  String get displayName {
    switch (this) {
      case PetType.dragon:
        return 'Rồng';
      case PetType.fox:
        return 'Cáo';
      case PetType.axolotl:
        return 'Axolotl';
    }
  }
}

class Pet {
  final String id;
  final String name;
  final PetType type;
  final int level;
  final int experience;
  final int evolutionStage;
  final int maxEvolutionStage;
  final bool isActive;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.level,
    required this.experience,
    required this.evolutionStage,
    required this.maxEvolutionStage,
    this.isActive = false,
  });

  // Tạo bản sao với các thuộc tính mới
  Pet copyWith({
    String? id,
    String? name,
    PetType? type,
    int? level,
    int? experience,
    int? evolutionStage,
    int? maxEvolutionStage,
    bool? isActive,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      evolutionStage: evolutionStage ?? this.evolutionStage,
      maxEvolutionStage: maxEvolutionStage ?? this.maxEvolutionStage,
      isActive: isActive ?? this.isActive,
    );
  }
  
  // Lấy màu sắc cho thú cưng dựa vào cấp độ tiến hóa
  Color getEvolutionColor() {
    switch (type) {
      case PetType.dragon:
        return evolutionStage == 1
            ? Colors.amber
            : evolutionStage == 2
            ? Colors.orange
            : evolutionStage == 3
            ? Colors.deepOrange
            : evolutionStage == 4
            ? Colors.red
            : Colors.redAccent;
      case PetType.fox:
        return evolutionStage == 1
            ? Colors.amber.shade200
            : evolutionStage == 2
            ? Colors.amber
            : evolutionStage == 3
            ? Colors.orange
            : evolutionStage == 4
            ? Colors.deepOrange
            : Colors.brown;
      case PetType.axolotl:
        return evolutionStage == 1
            ? Colors.pink.shade200
            : evolutionStage == 2
            ? Colors.pink
            : evolutionStage == 3
            ? Colors.pinkAccent
            : evolutionStage == 4
            ? Colors.purple
            : Colors.deepPurple;
    }
  }

  // Lấy kích thước icon dựa vào cấp độ tiến hóa
  double getEvolutionSize() {
    return 40.0 + (evolutionStage - 1) * 15.0;
  }

  // Lấy icon cho thú cưng dựa vào loại và cấp độ tiến hóa
  IconData getEvolutionIcon() {
    switch (type) {
      case PetType.dragon:
        return Pet.getIconForDragonLevel(evolutionStage);
      case PetType.fox:
        return Pet.getIconForFoxLevel(evolutionStage);
      case PetType.axolotl:
        return Pet.getIconForAxolotlLevel(evolutionStage);
    }
  }

  // Lấy asset path cho GIF animation
  String get gifAsset =>
      'assets/pets/${type.name.toLowerCase()}/evolution_$evolutionStage.gif';

  // Lấy asset path cho Lottie animation
  String get lottieAsset =>
      'assets/pets/${type.name.toLowerCase()}/evolution_$evolutionStage.json';

  // Lấy asset path cho hình ảnh tĩnh
  String get imageAsset =>
      'assets/pets/${type.name.toLowerCase()}/evolution_$evolutionStage.png';

  // Helper method để lấy icon cho Rồng theo cấp độ
  static IconData getIconForDragonLevel(int level) {
    switch (level) {
      case 1:
        return Icons.egg_alt;
      case 2:
        return Icons.egg_outlined;
      case 3:
        return Icons.cruelty_free;
      case 4:
        return Icons.pets;
      case 5:
      default:
        return Icons.architecture;
    }
  }

  // Helper method để lấy icon cho Cáo theo cấp độ
  static IconData getIconForFoxLevel(int level) {
    switch (level) {
      case 1:
        return Icons.egg_alt;
      case 2:
        return Icons.egg_outlined;
      case 3:
        return Icons.pets_outlined;
      case 4:
        return Icons.pets;
      case 5:
      default:
        return Icons.smart_toy;
    }
  }

  // Helper method để lấy icon cho Axolotl theo cấp độ
  static IconData getIconForAxolotlLevel(int level) {
    switch (level) {
      case 1:
        return Icons.egg_alt;
      case 2:
        return Icons.water_drop;
      case 3:
        return Icons.water;
      case 4:
        return Icons.waves;
      case 5:
      default:
        return Icons.water_outlined;
    }
  }
  
  // Chuyển đổi từ JSON
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      type: PetType.values.byName(json['type']),
      level: json['level'],
      experience: json['experience'],
      evolutionStage: json['evolutionStage'],
      maxEvolutionStage: json['maxEvolutionStage'],
      isActive: json['isActive'] ?? false,
    );
  }
  
  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'level': level,
      'experience': experience,
      'evolutionStage': evolutionStage,
      'maxEvolutionStage': maxEvolutionStage,
      'isActive': isActive,
    };
  }
}
