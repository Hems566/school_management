import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';

class DashboardService {
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final url = '${ApiConfig.apiUrl}/dashboard';
      print('Calling dashboard API: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await ApiConfig.getHeaders(),
      );

      print('Dashboard Response status: ${response.statusCode}');
      print('Dashboard Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Dashboard Decoded data: $data');
        return data;
      } else {
        throw Exception(
            'Erreur lors du chargement des données du tableau de bord');
      }
    } catch (e) {
      print('Dashboard service error: $e');
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      final url = '${ApiConfig.apiUrl}/dashboard/activities';
      print('Calling activities API: $url');

      final headers = await ApiConfig.getHeaders();
      print('Request headers: $headers');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Activities Response status: ${response.statusCode}');
      print('Activities Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Activities Decoded data: $data');
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception(
            'Erreur lors du chargement des activités récentes: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Activities service error: $e');
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }
}
