import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';

class ApiService {
  static const String _petsKey = 'pets_data';
  static const String _userPetKey = 'user_pet_';

  // Hàm giả lập lấy dữ liệu thú cưng từ API
  Future<List<Pet>> fetchPets(String userId) async {
    // Giả lập delay của API call
    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    final petsData = prefs.getString(_petsKey);

    if (petsData != null) {
      final List<dynamic> decodedData = jsonDecode(petsData);
      return decodedData.map((data) => Pet.fromJson(data)).toList();
    }

    // Nếu không có dữ liệu, tạo dữ liệu mẫu
    final defaultPets = _createDefaultPets(userId);

    // Lưu dữ liệu mẫu
    await _savePets(defaultPets);

    return defaultPets;
  }

  // Lưu danh sách thú cưng vào bộ nhớ local
  Future<void> _savePets(List<Pet> pets) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(pets.map((pet) => pet.toJson()).toList());
    await prefs.setString(_petsKey, encodedData);
  }

  // Đặt thú cưng đang hoạt động cho người dùng
  Future<void> setActivePet(String userId, String petId) async {
    // Giả lập delay của API call
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();

    // Lấy danh sách pet hiện tại
    final petsData = prefs.getString(_petsKey);

    if (petsData != null) {
      final List<dynamic> decodedData = jsonDecode(petsData);
      final List<Pet> pets =
          decodedData.map((data) => Pet.fromJson(data)).toList();

      // Cập nhật trạng thái active
      for (var i = 0; i < pets.length; i++) {
        if (pets[i].id == petId) {
          final updatedPet = pets[i].copyWith(isActive: true);
          pets[i] = updatedPet;
        } else {
          final updatedPet = pets[i].copyWith(isActive: false);
          pets[i] = updatedPet;
        }
      }

      // Lưu lại danh sách đã cập nhật
      await _savePets(pets);
    }

    // Lưu ID của pet đang active cho user
    await prefs.setString(_userPetKey + userId, petId);
  }

  // Cập nhật kinh nghiệm cho thú cưng
  Future<Pet> updatePetExperience(
    String userId,
    String petId,
    int newExp,
    int newLevel,
    int newEvolutionStage,
  ) async {
    // Giả lập delay của API call
    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    final petsData = prefs.getString(_petsKey);

    if (petsData == null) {
      throw Exception('Không tìm thấy dữ liệu thú cưng');
    }

    final List<dynamic> decodedData = jsonDecode(petsData);
    final List<Pet> pets =
        decodedData.map((data) => Pet.fromJson(data)).toList();

    // Tìm và cập nhật pet
    final int petIndex = pets.indexWhere((p) => p.id == petId);
    if (petIndex == -1) {
      throw Exception('Không tìm thấy thú cưng với ID: $petId');
    }

    // Tạo pet đã cập nhật
    final updatedPet = pets[petIndex].copyWith(
      experience: newExp,
      level: newLevel,
      evolutionStage: newEvolutionStage,
    );

    // Cập nhật trong danh sách
    pets[petIndex] = updatedPet;

    // Lưu danh sách cập nhật
    await _savePets(pets);

    return updatedPet;
  }

  // Tạo dữ liệu mẫu cho thú cưng
  List<Pet> _createDefaultPets(String userId) {
    return [
      Pet(
        id: 'pet_dragon_1',
        name: 'Draco',
        type: PetType.dragon,
        level: 1,
        experience: 0,
        evolutionStage: 1,
        maxEvolutionStage: 5,
        isActive: true,
      ),
      Pet(
        id: 'pet_fox_1',
        name: 'Foxy',
        type: PetType.fox,
        level: 1,
        experience: 0,
        evolutionStage: 1,
        maxEvolutionStage: 5,
        isActive: false,
      ),
      Pet(
        id: 'pet_axolotl_1',
        name: 'Axel',
        type: PetType.axolotl,
        level: 1,
        experience: 0,
        evolutionStage: 1,
        maxEvolutionStage: 5,
        isActive: false,
      ),
    ];
  }
}
