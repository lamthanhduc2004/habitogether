import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pet.dart';
import '../utils/config.dart';

class PetService {
  static String get baseUrl => AppConfig.getApiUrl();

  // Lấy danh sách pet của user
  Future<List<Pet>> getUserPets(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/pets'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pet.fromJson(json)).toList();
      } else {
        throw Exception('Không thể lấy danh sách pet');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Lấy pet hiện tại của user
  Future<Pet?> getCurrentPet(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/current-pet'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data != null ? Pet.fromJson(data) : null;
      } else {
        throw Exception('Không thể lấy pet hiện tại');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Cập nhật pet hiện tại của user
  Future<void> setCurrentPet(String userId, String petId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/current-pet'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'petId': petId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Không thể cập nhật pet hiện tại');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Thêm kinh nghiệm cho pet
  Future<Pet> addExperience(String petId, int amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pets/$petId/experience'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': amount}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pet.fromJson(data);
      } else {
        throw Exception('Không thể thêm kinh nghiệm');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Đổi tên pet
  Future<Pet> renamePet(String petId, String newName) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pets/$petId/name'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': newName}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pet.fromJson(data);
      } else {
        throw Exception('Không thể đổi tên pet');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
} 