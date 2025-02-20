import 'package:get/get.dart';
import 'package:school_management/controllers/auth_controller.dart';
import 'package:school_management/services/exam_service.dart';
import 'package:school_management/services/auth_service.dart';
import 'package:school_management/services/UserModel.dart';
import 'package:school_management/utils/app_notification.dart';

class ExamController extends GetxController {
  final ExamService examService;
  final AuthController _authController = Get.find<AuthController>();
  final AuthService _authService = Get.find<AuthService>();

  ExamController({required this.examService});

  final RxBool isLoading = false.obs;
  final RxBool isLoadingStudents = false.obs;
  final RxString error = ''.obs;

  // Liste observable pour les résultats
  final RxList<Map<String, dynamic>> results = <Map<String, dynamic>>[].obs;

  // Liste des étudiants
  final RxList<UserModel> students = <UserModel>[].obs;

  // ID de l'étudiant sélectionné
  final Rxn<int> selectedStudentId = Rxn<int>();

  // Track sélectionné
  final RxString selectedTrack = RxString('Réseaux et Systèmes Communicants');
  final RxString selectedSubject = RxString('');

  // Liste des tracks disponibles
  final tracks = ['Réseaux et Systèmes Communicants', 'Systèmes Informations'];

  // Résultat final observable
  final Rxn<Map<String, dynamic>> finalResult = Rxn<Map<String, dynamic>>();

  // Getters pour le rôle de l'utilisateur
  bool get isAdmin => _authController.currentUser.value?.role == 'admin';
  bool get isTeacher => _authController.currentUser.value?.role == 'teacher';
  bool get isStudent => _authController.currentUser.value?.role == 'student';

  // Charger la liste des étudiants par track
  // Charger tous les résultats (filtré par matière si sélectionnée)
  Future<void> loadAllResults() async {
    try {
      isLoading.value = true;
      error.value = '';

      if (selectedTrack.value.isEmpty) {
        results.clear();
        return;
      }

      final allResults = await examService.getTrackResults(
        selectedTrack.value,
        selectedSubject.value,
      );
      results.assignAll(allResults.cast<Map<String, dynamic>>());
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Sélectionner une matière
  void selectSubject(String subject) {
    selectedSubject.value = subject;
  }

  Future<void> loadStudentsByTrack(String? track) async {
    try {
      isLoadingStudents.value = true;
      if (track == null || track.isEmpty) {
        students.clear();
        return;
      }
      print('Loading students for track: $track');
      final List<dynamic> loadedStudents =
          await examService.getStudentsByTrack(track);
      print('Received students data: $loadedStudents');

      if (loadedStudents.isEmpty) {
        print('No students found for track: $track');
        students.clear();
        return;
      }

      try {
        final mappedStudents = loadedStudents.map((data) {
          print('Converting student data: $data');
          return UserModel.fromJson(data);
        }).toList();
        students.assignAll(mappedStudents);
        print('Successfully mapped ${students.length} students');
      } catch (e) {
        print('Error mapping students: $e');
        error.value = 'Erreur lors du chargement des étudiants: $e';
        AppNotification.showError('Erreur lors du chargement des étudiants');
      }
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoadingStudents.value = false;
    }
  }

  // Sauvegarder ou mettre à jour les résultats d'un examen
  Future<void> addOrUpdateGrade(
    int studentId,
    int subjectId,
    Map<String, dynamic> results,
  ) async {
    try {
      isLoading.value = true;
      error.value = '';

      if (selectedTrack.value.isEmpty) {
        error.value = 'Veuillez sélectionner un track';
        AppNotification.showError('Veuillez sélectionner un track');
        return;
      }

      await examService.createOrUpdateExamResults(
        studentId,
        subjectId,
        results,
        selectedTrack.value,
      );

      AppNotification.showSuccess('Notes enregistrées avec succès');
      await loadStudentResults(studentId);
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Charger les résultats d'un étudiant
  Future<void> loadStudentResults(int studentId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final studentResults = await examService.getStudentResults(studentId);
      results.assignAll(studentResults.cast<Map<String, dynamic>>());

      // Calculer la moyenne générale automatiquement
      calculateGeneralAverage(studentId);
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Charger les résultats pour une matière
  Future<void> loadSubjectResults(int subjectId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final subjectResults = await examService.getSubjectResults(subjectId);
      results.assignAll(subjectResults.cast<Map<String, dynamic>>());
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Calculer les résultats finaux
  Future<void> calculateGeneralAverage(int studentId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final result = await examService.calculateFinalResults(studentId);
      finalResult.value = result;

      AppNotification.showSuccess('Moyenne générale calculée avec succès');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Vérifier si l'étudiant est validé
  bool isValidated(double generalAverage) {
    return generalAverage >= 10.0;
  }

  // Garder la compatibilité avec l'ancienne méthode loadStudents
  Future<void> loadStudents() async {
    if (selectedTrack.value.isNotEmpty) {
      await loadStudentsByTrack(selectedTrack.value);
    }
  }

  // Sélectionner un track
  void selectTrack(String? track) {
    if (track == null) return;
    selectedTrack.value = track;
    loadStudentsByTrack(track);
  }

  void reset() {
    results.clear();
    finalResult.value = null;
    error.value = '';
    selectedStudentId.value = null;
    selectedTrack.value = '';
  }
}
