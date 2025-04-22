import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/config.dart';

class AuthService {
  // Lấy base URL từ config
  static String get baseUrl => AppConfig.getApiUrl();

  // Đăng nhập
  Future<Map<String, dynamic>> login(String email, String password, String lang) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password, "lang": lang}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Đảm bảo response luôn có trường success
        return {
          "success": true,
          ...responseData
        };
      } else {
        return {
          "success": false,
          "message": responseData["message"] ?? "Đăng nhập thất bại"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Không thể kết nối đến máy chủ: $e"
      };
    }
  }

  // Đăng ký
  Future<Map<String, dynamic>> register(String fullName, String email, String password, String lang) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"fullName": fullName, "email": email, "password": password, "lang": lang}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
    
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Đảm bảo response luôn có trường success
        return {
          "success": true,
          ...responseData
        };
      } else {
        return {
          "success": false,
          "message": responseData["message"] ?? "Đăng ký thất bại"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Không thể kết nối đến máy chủ: $e"
      };
    }
  }
}
