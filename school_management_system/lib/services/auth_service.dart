import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_management/services/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api/auth';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  String? _token;
  UserModel? _currentUser;

  String get token => _token ?? '';
  UserModel? get currentUser => _currentUser;

  Future<Map<String, String>> _getHeaders() async {
    if (_token == null) {
      _token = await getToken();
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> _saveToken(String newToken) async {
    _token = newToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, newToken);
  }

  Future<void> _saveUserData(UserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, json.encode(user.toJson()));
  }

  Future<UserModel?> _getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(userKey);
    if (userStr != null) {
      try {
        _currentUser = UserModel.fromJson(json.decode(userStr));
        return _currentUser;
      } catch (e) {
        print('Error parsing saved user data: $e');
        await prefs.remove(userKey);
      }
    }
    return null;
  }

  Future<void> _clearUserData() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = UserModel.fromJson(data['user']);
        await _saveToken(data['token']);
        await _saveUserData(user);
        return user;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Échec de la connexion');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      final headers = await _getHeaders();
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _clearUserData();
    }
  }

  Future<UserModel?> getUserDetails() async {
    try {
      final savedUser = await _getSavedUserData();
      if (savedUser != null) {
        final headers = await _getHeaders();
        final response = await http.get(
          Uri.parse('$baseUrl/user'),
          headers: headers,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final user = UserModel.fromJson(data);
          await _saveUserData(user);
          return user;
        } else {
          await _clearUserData();
          return null;
        }
      }
      return null;
    } catch (e) {
      print('GetUserDetails error: $e');
      await _clearUserData();
      return null;
    }
  }

  Future<List<UserModel>> getTeachers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/teachers'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((user) => UserModel.fromJson(user))
            .toList();
      } else {
        throw Exception('Impossible de récupérer la liste des enseignants');
      }
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getRegistrationRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/registration-requests'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Impossible de récupérer les demandes d\'inscription');
      }
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  Future<void> approveRegistration(int requestId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/registration-requests/$requestId/approve'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Impossible d\'approuver la demande');
      }
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  Future<void> rejectRegistration(int requestId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/registration-requests/$requestId/reject'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Impossible de rejeter la demande');
      }
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  Future<bool> register({
    required String email,
    required String name,
    required String rollNumber,
    required String className,
    required String phoneNumber,
    String? role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'name': name,
          'rollNumber': rollNumber,
          'className': className,
          'phoneNumber': phoneNumber,
          'role': role ?? 'student',
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Échec de l\'inscription');
      }
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception('Impossible d\'envoyer l\'email de réinitialisation');
      }
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Impossible de réinitialiser le mot de passe');
      }
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }
}
