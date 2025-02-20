import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_management/services/auth_service.dart';

class ExamService {
  static const String baseUrl = 'http://localhost:3000/api/exam';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Récupérer l'ID étudiant à partir de l'ID utilisateur
  Future<int> getStudentId(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/student/user/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['id'];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get student ID');
      }
    } catch (e) {
      print('Error getting student ID: $e');
      rethrow;
    }
  }

  // Récupérer les étudiants par track
  Future<List<dynamic>> getStudentsByTrack(String? track) async {
    if (track == null || track.isEmpty) {
      return [];
    }
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/students/track/${Uri.encodeComponent(track)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get students by track');
      }
    } catch (e) {
      print('Error in getStudentsByTrack: $e');
      rethrow;
    }
  }

  // Créer ou mettre à jour les résultats d'un examen
  Future<Map<String, dynamic>> createOrUpdateExamResults(
    int studentId,
    int subjectId,
    Map<String, dynamic> results,
    String? track,
  ) async {
    try {
      final headers = await _getHeaders();
      if (track == null || track.isEmpty) {
        throw Exception('Track is required');
      }

      final body = json.encode({
        'studentId': studentId,
        'subjectId': subjectId,
        'track': track,
        'results': {
          'tp_score': results['tp_score'],
          'continuous_assessment_score': results['continuous_assessment_score'],
          'final_exam_score': results['final_exam_score'],
          'retake_score': results['retake_score'],
        },
      });

      final response = await http.post(
        Uri.parse('$baseUrl/results'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to save exam results');
      }
    } catch (e) {
      print('Error in createOrUpdateExamResults: $e');
      rethrow;
    }
  }

  // Récupérer les résultats d'un étudiant
  Future<List<dynamic>> getStudentResults(int studentId) async {
    try {
      print('Fetching results for student ID: $studentId');
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/results/student/$studentId'),
        headers: headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get student results');
      }
    } catch (e) {
      print('Error in getStudentResults: $e');
      rethrow;
    }
  }

  // Récupérer les résultats pour une matière
  Future<List<dynamic>> getSubjectResults(int subjectId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/results/subject/$subjectId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get subject results');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Récupérer les résultats pour un track (optionnellement filtré par matière)
  Future<List<dynamic>> getTrackResults(String track, String subject) async {
    try {
      final headers = await _getHeaders();
      var url = '$baseUrl/results/track/${Uri.encodeComponent(track)}';

      if (subject.isNotEmpty) {
        url += '?subject=${Uri.encodeComponent(subject)}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Impossible de récupérer les résultats');
      }
    } catch (e) {
      print('Error in getTrackResults: $e');
      rethrow;
    }
  }

  // Calculer les résultats finaux d'un étudiant
  Future<Map<String, dynamic>> calculateFinalResults(int studentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/results/student/$studentId/calculate-final'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Failed to calculate final results');
      }
    } catch (e) {
      rethrow;
    }
  }
}
