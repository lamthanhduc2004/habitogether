import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';
import '../utils/api_service.dart';

class PetProvider extends ChangeNotifier {
  Pet? _activePet;
  final List<Pet> _pets = [];
  final PetService _petService = PetService();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _error;

  // Cache để tránh mất thú cưng khi rebuild
  Pet? _cachedActivePet;

  // Constructor
  PetProvider() {
    // Không khởi tạo dữ liệu tĩnh nữa
  }

  // Getter cho trạng thái loading
  bool get isLoading => _isLoading;

  // Getter cho lỗi
  String? get error => _error;

  // Getter cho thú cưng hiện tại
  Pet? get activePet => _activePet;

  // Getter cho danh sách thú cưng
  List<Pet> get pets => List.unmodifiable(_pets);

  // Tải dữ liệu pet từ server
  Future<void> loadPets(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Lấy danh sách pet
      final petsData = await _apiService.fetchPets(userId);
      _pets.clear();
      _pets.addAll(petsData);

      // Lấy pet hiện tại
      _activePet = _pets.firstWhere(
        (pet) => pet.isActive,
        orElse: () => _pets.isNotEmpty ? _pets.first : _pets.first,
      );

      if (_activePet == null && _pets.isNotEmpty) {
        _activePet = _pets.first;
        await setActivePet(userId, _activePet!.id);
      }

      _cachedActivePet = _activePet;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Không thể tải thông tin thú cưng: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Khôi phục pet hiện tại từ cache nếu có
  void restoreFromCache() {
    if (_cachedActivePet != null) {
      _activePet = _cachedActivePet;
      notifyListeners();
    }
  }

  // Thay đổi thú cưng hiện tại
  Future<void> setActivePet(String userId, String petId) async {
    try {
      await _apiService.setActivePet(userId, petId);
      
      await loadPets(userId);
      
      notifyListeners();
    } catch (e) {
      _error = 'Không thể đặt thú cưng hiện tại: $e';
      notifyListeners();
    }
  }

  // Thêm kinh nghiệm cho thú cưng hiện tại
  Future<void> addExperience(String userId, int amount) async {
    if (_activePet == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedPet = await _petService.addExperience(_activePet!.id, amount);

      // Cập nhật thú cưng trong danh sách
      final index = _pets.indexWhere((pet) => pet.id == updatedPet.id);
      if (index != -1) {
        _pets[index] = updatedPet;
        _activePet = updatedPet;
        _cachedActivePet = updatedPet;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Đặt tên cho thú cưng
  Future<void> renamePet(String userId, String petId, String newName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedPet = await _petService.renamePet(petId, newName);

      // Cập nhật thú cưng trong danh sách
      final index = _pets.indexWhere((pet) => pet.id == updatedPet.id);
      if (index != -1) {
        _pets[index] = updatedPet;
      }

      if (_activePet?.id == petId) {
        _activePet = updatedPet;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tăng kinh nghiệm cho thú cưng
  Future<void> gainExperience(String userId, String petId, int amount) async {
    try {
      // Tìm pet trong danh sách local
      final petIndex = _pets.indexWhere((p) => p.id == petId);
      if (petIndex == -1) throw Exception('Không tìm thấy thú cưng');

      // Lấy thông tin pet hiện tại
      final pet = _pets[petIndex];

      // Tính toán kinh nghiệm mới
      final currentExp = pet.experience;
      final maxExp = 50 * pet.level * pet.evolutionStage;
      var newExp = currentExp + amount;
      var newLevel = pet.level;
      var newEvolutionStage = pet.evolutionStage;

      // Kiểm tra nếu đủ exp để lên level
      if (newExp >= maxExp) {
        // Level up
        newExp = newExp - maxExp;
        newLevel++;

        // Kiểm tra nếu đủ level để tiến hóa
        if (newLevel > 5 && newEvolutionStage < pet.maxEvolutionStage) {
          newLevel = 1;
          newEvolutionStage++;
        }
      }

      // Gọi API để cập nhật dữ liệu
      final updatedPet = await _apiService.updatePetExperience(
        userId,
        petId,
        newExp,
        newLevel,
        newEvolutionStage,
      );

      // Cập nhật dữ liệu local
      _pets[petIndex] = updatedPet;

      // Cập nhật active pet nếu cần
      if (_activePet?.id == petId) {
        _activePet = updatedPet;
        _cachedActivePet = updatedPet;
      }

      notifyListeners();
    } catch (e) {
      _error = 'Không thể tăng kinh nghiệm cho thú cưng: $e';
      notifyListeners();
    }
  }
}
