import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:school_management/services/auth_service.dart';

class TeacherService extends GetxService {
  static const String baseUrl = 'http://localhost:3000/api/teachers';
  final AuthService _authService = Get.find<AuthService>();

  Future<String?> _getToken() async {
    return await _authService.getToken();
  }

  // Récupérer tous les enseignants avec leurs matières
  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        }
        throw Exception('Invalid response format');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to load teachers');
      }
    } catch (e) {
      print('Error getting teachers: ${e.toString()}');
      throw Exception('Error getting teachers: $e');
    }
  }

  // Récupérer toutes les matières disponibles
  Future<List<Map<String, dynamic>>> getAvailableSubjects() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse('$baseUrl/subjects'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        }
        throw Exception('Invalid response format');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to load subjects');
      }
    } catch (e) {
      print('Error getting subjects: ${e.toString()}');
      throw Exception('Error getting subjects: $e');
    }
  }

  // Créer un nouvel enseignant
  Future<Map<String, dynamic>> createTeacher({
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    required int userId,
    required List<int> subjectIds,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'user_id': userId,
          'subject_ids': subjectIds,
        }),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['data'] ?? jsonResponse;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create teacher');
      }
    } catch (e) {
      print('Error creating teacher: ${e.toString()}');
      throw Exception('Error creating teacher: $e');
    }
  }

  // Mettre à jour un enseignant
  Future<void> updateTeacher({
    required int id,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required List<int> subjectIds,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'subject_ids': subjectIds,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update teacher');
      }
    } catch (e) {
      print('Error updating teacher: ${e.toString()}');
      throw Exception('Error updating teacher: $e');
    }
  }

  // Supprimer un enseignant
  Future<void> deleteTeacher(int id) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete teacher');
      }
    } catch (e) {
      print('Error deleting teacher: ${e.toString()}');
      throw Exception('Error deleting teacher: $e');
    }
  }
}
