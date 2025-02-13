import 'package:get/get.dart';
import 'package:school_management/controllers/auth_controller.dart';
import 'package:school_management/controllers/exam_controller.dart';
import 'package:school_management/controllers/home_controller.dart';
import 'package:school_management/controllers/request_login_controller.dart';
import 'package:school_management/controllers/subject_controller.dart';
import 'package:school_management/controllers/teacher_controller.dart';
import 'package:school_management/services/auth_service.dart';
import 'package:school_management/services/exam_service.dart';
import 'package:school_management/services/schedule_service.dart';
import 'package:school_management/services/subject_service.dart';
import 'package:school_management/services/teacher_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Services - Ne pas réinjecter AuthService car déjà injecté dans main.dart
    Get.put<TeacherService>(
      TeacherService(),
      permanent: true,
    );
    Get.put(AuthService(), permanent: true);
    Get.put<SubjectService>(
      SubjectService(),
      permanent: true,
    );
    // S'assurer que le token est disponible
    final authService = Get.find<AuthService>();
    final token = authService.token;

    // Injecter les services qui ne dépendent pas du token
    Get.put<ExamService>(
      ExamService(),
      permanent: true,
    );

    // Injecter les services qui dépendent du token
    Get.put<ScheduleService>(
      ScheduleService(token),
      permanent: true,
    );

    // Controllers - Ne pas réinjecter AuthController car déjà injecté dans main.dart
    Get.put<HomeController>(
      HomeController(authService: Get.find<AuthService>()),
      permanent: true,
    );
    Get.put<TeacherController>(
      TeacherController(teacherService: Get.find<TeacherService>()),
      permanent: true,
    );
    Get.put<RequestLoginController>(
      RequestLoginController(authService: Get.find<AuthService>()),
      permanent: true,
    );
    Get.put<SubjectController>(
      SubjectController(subjectService: Get.find<SubjectService>()),
      permanent: true,
    );
    Get.put<ExamController>(
      ExamController(examService: Get.find<ExamService>()),
      permanent: true,
    );

    // S'assurer que les contrôleurs sont correctement initialisés
    final authController = Get.find<AuthController>();
    final examController = Get.find<ExamController>();
    final subjectController = Get.find<SubjectController>();

    // Initialiser les données si nécessaire
    if (authController.isLoggedIn.value) {
      if (authController.isTeacher) {
        // Charger les données initiales pour un enseignant
        examController.loadStudents();
      } else if (authController.isAdmin) {
        // Charger les données initiales pour un admin
        subjectController.loadSubjects();
      }
    }
  }
}
