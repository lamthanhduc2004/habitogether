import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/config.dart';

class ApiService {
  static String get baseUrl => AppConfig.getApiUrl();
  
  // Gửi request GET
  Future<dynamic> getData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load data");
    }
  }

  // Gửi request POST
  Future<dynamic> postData(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to send data");
    }
  }
}
