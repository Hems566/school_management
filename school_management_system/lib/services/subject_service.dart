import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:school_management/services/auth_service.dart';

class SubjectService extends GetxService {
  static const String baseUrl = 'http://localhost:3000/api/subjects';
  final AuthService _authService = Get.find<AuthService>();

  Future<String?> _getToken() async {
    return await _authService.getToken();
  }

  // Récupérer tous les tracks disponibles
  Future<List<String>> getTracks() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await http.get(
        Uri.parse('$baseUrl/tracks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return List<String>.from(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Erreur lors du chargement des tracks');
      }
    } catch (e) {
      print('Error getting tracks: $e');
      throw Exception('Erreur de connexion au serveur');
    }
  }

  // Récupérer tous les enseignants disponibles
  Future<List<Map<String, dynamic>>> getAvailableTeachers() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await http.get(
        Uri.parse('$baseUrl/teachers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Erreur lors du chargement des enseignants');
      }
    } catch (e) {
      print('Error getting available teachers: $e');
      throw Exception('Erreur de connexion au serveur');
    }
  }

  // Récupérer toutes les matières
  Future<List<Map<String, dynamic>>> getAllSubjects() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Erreur lors du chargement des matières');
      }
    } catch (e) {
      print('Error getting subjects: $e');
      throw Exception('Erreur de connexion au serveur');
    }
  }

  // Récupérer les matières d'un enseignant
  Future<List<Map<String, dynamic>>> getTeacherSubjects(int teacherId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await http.get(
        Uri.parse('$baseUrl/teacher/$teacherId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ??
            'Erreur lors du chargement des matières de l\'enseignant');
      }
    } catch (e) {
      print('Error getting teacher subjects: $e');
      throw Exception('Erreur de connexion au serveur');
    }
  }

  // Créer une nouvelle matière
  Future<Map<String, dynamic>> createSubject({
    required String name,
    required String track,
    required List<int> teacherIds,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'track': track,
          'teacherIds': teacherIds,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Erreur lors de la création de la matière');
      }
    } catch (e) {
      print('Error creating subject: $e');
      throw Exception('Erreur de connexion au serveur');
    }
  }

  // Mettre à jour une matière
  Future<Map<String, dynamic>> updateSubject({
    required int id,
    required String name,
    required String track,
    required List<int> teacherIds,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'track': track,
          'teacherIds': teacherIds,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Erreur lors de la mise à jour de la matière');
      }
    } catch (e) {
      print('Error updating subject: $e');
      throw Exception('Erreur de connexion au serveur');
    }
  }

  // Supprimer une matière
  Future<void> deleteSubject(int id) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Erreur lors de la suppression de la matière');
      }
    } catch (e) {
      print('Error deleting subject: $e');
      throw Exception('Erreur de connexion au serveur');
    }
  }
}
