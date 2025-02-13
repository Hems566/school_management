import 'package:get/get.dart';
import 'package:school_management/services/teacher_service.dart';
import 'package:school_management/utils/app_notification.dart';

class TeacherController extends GetxController {
  final TeacherService teacherService;

  TeacherController({required this.teacherService});

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList teachers = [].obs;
  final RxList<Map<String, dynamic>> availableSubjects =
      <Map<String, dynamic>>[].obs;
  final RxList<int> selectedSubjectIds = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTeachers();
    loadAvailableSubjects();
  }

  // Charger la liste des enseignants
  Future<void> loadTeachers() async {
    try {
      isLoading.value = true;
      error.value = '';
      final teachersList = await teacherService.getAllTeachers();
      teachers.assignAll(teachersList);
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(
          'Erreur lors du chargement des enseignants: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Charger la liste des matières disponibles
  Future<void> loadAvailableSubjects() async {
    try {
      final subjects = await teacherService.getAvailableSubjects();
      availableSubjects.assignAll(subjects);
      print('Matières chargées: ${availableSubjects.length}');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError('Erreur lors du chargement des matières: $e');
    }
  }

  // Créer un nouvel enseignant
  Future<bool> createTeacher({
    required String firstName,
    required String lastName,
    required String email,
    required int userId,
    String? phoneNumber,
    required List<int> subjectIds,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      await teacherService.createTeacher(
        firstName: firstName,
        lastName: lastName,
        email: email,
        userId: userId,
        phoneNumber: phoneNumber,
        subjectIds: subjectIds,
      );

      await loadTeachers(); // Recharger la liste
      AppNotification.showSuccess('Enseignant créé avec succès');
      return true;
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError('Erreur lors de la création: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour un enseignant
  Future<bool> updateTeacher({
    required int id,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required List<int> subjectIds,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      await teacherService.updateTeacher(
        id: id,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        subjectIds: subjectIds,
      );

      await loadTeachers(); // Recharger la liste
      AppNotification.showSuccess('Enseignant mis à jour avec succès');
      return true;
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError('Erreur lors de la mise à jour: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer un enseignant
  Future<bool> deleteTeacher(int id) async {
    try {
      isLoading.value = true;
      error.value = '';

      await teacherService.deleteTeacher(id);
      await loadTeachers(); // Recharger la liste
      AppNotification.showSuccess('Enseignant supprimé avec succès');
      return true;
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError('Erreur lors de la suppression: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Sélectionner une matière
  void selectSubject(int subjectId) {
    if (!selectedSubjectIds.contains(subjectId)) {
      selectedSubjectIds.add(subjectId);
    }
  }

  // Désélectionner une matière
  void unselectSubject(int subjectId) {
    selectedSubjectIds.remove(subjectId);
  }

  // Réinitialiser la sélection des matières
  void clearSelectedSubjects() {
    selectedSubjectIds.clear();
  }

  // Définir la liste des matières sélectionnées
  void setSelectedSubjects(List<int> subjectIds) {
    selectedSubjectIds.assignAll(subjectIds);
  }

  // Réinitialiser les erreurs
  void clearError() {
    error.value = '';
  }

  @override
  void onClose() {
    clearSelectedSubjects();
    super.onClose();
  }
}
