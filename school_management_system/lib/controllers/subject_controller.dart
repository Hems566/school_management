import 'package:get/get.dart';
import 'package:school_management/models/subject_model.dart';
import 'package:school_management/services/subject_service.dart';
import 'package:school_management/utils/app_notification.dart';

class SubjectController extends GetxController {
  final SubjectService subjectService;

  SubjectController({required this.subjectService});

  final RxList<Subject> subjects = <Subject>[].obs;
  final RxList<Map<String, dynamic>> availableTeachers =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Track actuel
  final RxString currentTrack = ''.obs;
  // Liste des IDs des enseignants sélectionnés
  final RxList<int> selectedTeacherIds = <int>[].obs;

  // Charger tous les enseignants disponibles
  Future<void> loadAvailableTeachers() async {
    try {
      isLoading.value = true;
      final teachers = await subjectService.getAvailableTeachers();
      availableTeachers.assignAll(teachers);
      print('Enseignants chargés: ${availableTeachers.length}');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Charger toutes les matières
  Future<void> loadSubjects() async {
    try {
      isLoading.value = true;
      final data = await subjectService.getAllSubjects();
      subjects.value = data.map((json) {
        if (json['teachers'] != null) {
          json['teachers'] = (json['teachers'] as List).map((teacher) {
            return {
              'id': teacher['id'],
              'name': teacher['name'],
            };
          }).toList();
        }
        return Subject.fromJson(json);
      }).toList();
      print('Matières chargées: ${subjects.length}');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Charger les matières d'un enseignant
  Future<void> loadTeacherSubjects(int teacherId) async {
    try {
      isLoading.value = true;
      final data = await subjectService.getTeacherSubjects(teacherId);
      subjects.value = data.map((json) => Subject.fromJson(json)).toList();
      print('Matières de l\'enseignant chargées: ${subjects.length}');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSubject({
    required String name,
    required String track,
    required List<int> teacherIds,
  }) async {
    try {
      isLoading.value = true;
      await subjectService.createSubject(
        name: name,
        track: track,
        teacherIds: teacherIds,
      );
      await loadSubjects();
      AppNotification.showSuccess('Matière créée avec succès');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSubject({
    required int id,
    required String name,
    required String track,
    required List<int> teacherIds,
  }) async {
    try {
      isLoading.value = true;
      await subjectService.updateSubject(
        id: id,
        name: name,
        track: track,
        teacherIds: teacherIds,
      );
      await loadSubjects();
      AppNotification.showSuccess('Matière mise à jour avec succès');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSubject(int id) async {
    try {
      isLoading.value = true;
      await subjectService.deleteSubject(id);
      await loadSubjects();
      AppNotification.showSuccess('Matière supprimée avec succès');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void selectTeacher(int teacherId) {
    if (!selectedTeacherIds.contains(teacherId)) {
      selectedTeacherIds.add(teacherId);
    }
  }

  void unselectTeacher(int teacherId) {
    selectedTeacherIds.remove(teacherId);
  }

  void clearSelectedTeachers() {
    selectedTeacherIds.clear();
  }

  @override
  void onInit() {
    super.onInit();
    loadSubjects();
    loadAvailableTeachers();
  }

  @override
  void onClose() {
    clearSelectedTeachers();
    super.onClose();
  }
}
