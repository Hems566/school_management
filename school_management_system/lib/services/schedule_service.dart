import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';

class ScheduleEntry {
  final int id;
  final int teacherId;
  final int subjectId;
  final String className;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String roomNumber;
  final String? teacherName;
  final String? subjectName;

  ScheduleEntry({
    required this.id,
    required this.teacherId,
    required this.subjectId,
    required this.className,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
    this.teacherName,
    this.subjectName,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      id: json['id'],
      teacherId: json['teacher_id'],
      subjectId: json['subject_id'],
      className: json['className'],
      dayOfWeek: json['day_of_week'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      roomNumber: json['room_number'],
      teacherName: json['teacher_name'],
      subjectName: json['subject_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher_id': teacherId,
      'subject_id': subjectId,
      'className': className,
      'day_of_week': dayOfWeek,
      'start_time': "${startTime}:00",
      'end_time': "${endTime}:00",
      'room_number': roomNumber,
    };
  }
}

class ScheduleService {
  final String baseUrl = ApiConfig.baseUrl;
  final String token;

  ScheduleService(this.token);

  Future<List<ScheduleEntry>> getAllSchedules() async {
    final response = await http.get(
      Uri.parse('$baseUrl/schedule'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => ScheduleEntry.fromJson(json))
          .toList();
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<List<ScheduleEntry>> getTeacherSchedule(int teacherId) async {
    print('\nRequête getTeacherSchedule:');
    final url = '$baseUrl/schedule/teacher/$teacherId';
    print('URL: $url');
    print('Token: ${token.isEmpty ? "VIDE" : "${token.substring(0, 10)}..."}');
    print('TeacherId: $teacherId (type: ${teacherId.runtimeType})');

    try {
      if (token.isEmpty) {
        throw Exception('Token manquant');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final schedules = (data['data'] as List)
            .map((json) => ScheduleEntry.fromJson(json))
            .toList();
        print('Nombre d\'emplois du temps reçus: ${schedules.length}');
        return schedules;
      } else {
        final error = jsonDecode(response.body);
        print('Erreur: ${error['message']}');
        throw Exception(error['message']);
      }
    } catch (e) {
      print('Exception lors de la requête: $e');
      rethrow;
    }
  }

  Future<List<ScheduleEntry>> getClassSchedule(String className) async {
    print('\nRequête getClassSchedule:');
    final encodedClassName = Uri.encodeComponent(className);
    final url = '$baseUrl/schedule/class/$encodedClassName';
    print('URL: $url');
    print('Token: ${token.isEmpty ? "VIDE" : "${token.substring(0, 10)}..."}');
    print('ClassName: $className (encoded: $encodedClassName)');

    try {
      if (token.isEmpty) {
        throw Exception('Token manquant');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final schedules = (data['data'] as List)
            .map((json) => ScheduleEntry.fromJson(json))
            .toList();
        print('Nombre d\'emplois du temps reçus: ${schedules.length}');
        return schedules;
      } else {
        final error = jsonDecode(response.body);
        print('Erreur: ${error['message']}');
        throw Exception(error['message']);
      }
    } catch (e) {
      print('Exception lors de la requête: $e');
      rethrow;
    }
  }

  Future<ScheduleEntry> createSchedule(ScheduleEntry schedule) async {
    final response = await http.post(
      Uri.parse('$baseUrl/schedule'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(schedule.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ScheduleEntry.fromJson(data['data']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<ScheduleEntry> updateSchedule(int id, ScheduleEntry schedule) async {
    final response = await http.put(
      Uri.parse('$baseUrl/schedule/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(schedule.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ScheduleEntry.fromJson(data['data']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> deleteSchedule(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/schedule/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}
