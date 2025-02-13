import 'package:get/get.dart';
import '../services/schedule_service.dart';
import '../services/auth_service.dart';

enum ScheduleStatus { initial, loading, success, error }

class UserScheduleController extends GetxController {
  final ScheduleService _scheduleService;
  final AuthService _authService;

  final schedules = <ScheduleEntry>[].obs;
  final status = ScheduleStatus.initial.obs;
  final errorMessage = ''.obs;

  UserScheduleController(this._scheduleService, this._authService);

  // Helper pour normaliser les chaînes de caractères pour la comparaison
  String _normalizeString(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '');
  }

  // Fonction helper pour convertir les jours en valeurs numériques pour le tri
  int _getDayValue(String day) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days.indexOf(day);
  }

  @override
  void onInit() {
    super.onInit();
    final user = _authService.currentUser;
    if (user != null) {
      print('UserScheduleController - Utilisateur connecté: ${user.role}');
      loadSchedule();
    } else {
      print('UserScheduleController - Aucun utilisateur connecté');
      Get.offAllNamed('/login');
    }
  }

  @override
  void onReady() {
    super.onReady();
    final user = _authService.currentUser;
    if (user != null && !['teacher', 'student'].contains(user.role)) {
      print(
          'UserScheduleController - Accès non autorisé pour le rôle: ${user.role}');
      Get.back();
    }
  }

  Future<void> loadSchedule() async {
    try {
      print('Début du chargement de l\'emploi du temps');
      status.value = ScheduleStatus.loading;
      errorMessage.value = '';

      final user = _authService.currentUser;
      print('Utilisateur récupéré: ${user?.toJson()}');

      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      print('Chargement de tous les emplois du temps');
      List<ScheduleEntry> allSchedules =
          await _scheduleService.getAllSchedules();
      print('Emplois du temps chargés: ${allSchedules.length}');

      if (user.role == 'teacher') {
        print('Filtrage pour l\'enseignant - Nom: ${user.name}');
        allSchedules = allSchedules.where((schedule) {
          final teacherName = schedule.teacherName?.toLowerCase().trim();
          final userName = user.name?.toLowerCase().trim();
          final matches = teacherName == userName;
          print('Comparaison noms: "$teacherName" avec "$userName" = $matches');
          return matches;
        }).toList();
      } else if (user.role == 'student') {
        print('\nDébut du filtrage pour étudiant:');
        print('Données de l\'utilisateur:');
        print('  - className: "${user.className}"');
        print('  - track: "${user.track}"');
        print('  - masterProgram: "${user.masterProgram}"');

        print('\nClasses disponibles dans l\'emploi du temps:');
        final availableClasses = allSchedules.map((s) => s.className).toSet();
        for (var className in availableClasses) {
          print('  - "$className"');
        }

        if (user.track == null || user.track!.isEmpty) {
          throw Exception('Aucune classe assignée à cet étudiant');
        }

        allSchedules = allSchedules.where((schedule) {
          final normalizedScheduleClass = _normalizeString(schedule.className);
          final normalizedUserTrack = _normalizeString(user.track!);
          final matches = normalizedScheduleClass == normalizedUserTrack;

          print('\nComparaison détaillée:');
          print('  Schedule class: "${schedule.className}"');
          print('  Normalized schedule: "$normalizedScheduleClass"');
          print('  User track: "${user.track}"');
          print('  Normalized track: "$normalizedUserTrack"');
          print('  Matches: $matches');

          return matches;
        }).toList();

        print('\nRésultat du filtrage: ${allSchedules.length} entrées');
      } else {
        throw Exception('Type d\'utilisateur non supporté: ${user.role}');
      }

      if (allSchedules.isEmpty) {
        print('Aucun emploi du temps trouvé pour cet utilisateur');
      } else {
        print('\nDétails des emplois du temps:');
        for (var schedule in allSchedules) {
          print('''
            ID: ${schedule.id}
            TeacherID: ${schedule.teacherId}
            TeacherName: ${schedule.teacherName}
            Classe: ${schedule.className}
            Matière: ${schedule.subjectName}
            Jour: ${schedule.dayOfWeek}
            Horaire: ${schedule.startTime}-${schedule.endTime}
            ''');
        }
      }

      allSchedules.sort((a, b) {
        int dayCompare =
            _getDayValue(a.dayOfWeek).compareTo(_getDayValue(b.dayOfWeek));
        if (dayCompare != 0) return dayCompare;
        return a.startTime.compareTo(b.startTime);
      });

      print('Application du tri terminée');
      schedules.assignAll(allSchedules);

      print(
          'Chargement terminé avec succès. Nombre d\'entrées: ${schedules.length}');
      status.value = ScheduleStatus.success;
    } catch (e, stackTrace) {
      print('Erreur lors du chargement de l\'emploi du temps:');
      print('Message: ${e.toString()}');
      print('StackTrace: $stackTrace');
      errorMessage.value = e.toString();
      status.value = ScheduleStatus.error;
    }
  }
}
