import 'package:get/get.dart';
import '../services/auth_service.dart';

class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  static String get apiUrl => baseUrl;

  static Future<Map<String, String>> getHeaders() async {
    final AuthService authService = Get.find<AuthService>();
    final token = authService.token;

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
