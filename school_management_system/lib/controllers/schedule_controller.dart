import 'package:get/get.dart';
import '../services/schedule_service.dart';
import '../services/auth_service.dart';
import '../services/teacher_service.dart';
import '../services/subject_service.dart';
import '../utils/app_notification.dart';

class ScheduleController extends GetxController {
  final teacherService = TeacherService();
  final subjectService = SubjectService();
  final RxList<Map<String, dynamic>> teachers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> subjects = <Map<String, dynamic>>[].obs;
  final RxList<String> classes = <String>[].obs;
  final scheduleService = ScheduleService(Get.find<AuthService>().token);
  final RxList<ScheduleEntry> schedules = <ScheduleEntry>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSchedules();
    loadTeachers();
    loadSubjects();
    loadClasses();
  }

  Future<void> loadTeachers() async {
    try {
      teachers.value = await teacherService.getAllTeachers();
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    }
  }

  Future<void> loadSubjects() async {
    try {
      subjects.value = await subjectService.getAllSubjects();
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    }
  }

  Future<void> loadClasses() async {
    try {
      // Charger les tracks depuis le service des matières
      classes.value = await subjectService.getTracks();
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    }
  }

  Future<void> loadSchedules() async {
    try {
      isLoading.value = true;
      schedules.value = await scheduleService.getAllSchedules();
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTeacherSchedule(int teacherId) async {
    try {
      isLoading.value = true;
      schedules.value = await scheduleService.getTeacherSchedule(teacherId);
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadClassSchedule(String className) async {
    try {
      isLoading.value = true;
      schedules.value = await scheduleService.getClassSchedule(className);
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSchedule({
    required int teacherId,
    required int subjectId,
    required String className,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required String roomNumber,
  }) async {
    try {
      isLoading.value = true;
      final entry = ScheduleEntry(
        id: 0,
        teacherId: teacherId,
        subjectId: subjectId,
        className: className,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        roomNumber: roomNumber,
      );
      await scheduleService.createSchedule(entry);
      await loadSchedules(); // Recharger la liste
      AppNotification.showSuccess('Emploi du temps créé avec succès');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSchedule({
    required int id,
    required int teacherId,
    required int subjectId,
    required String className,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required String roomNumber,
  }) async {
    try {
      isLoading.value = true;
      final entry = ScheduleEntry(
        id: id,
        teacherId: teacherId,
        subjectId: subjectId,
        className: className,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        roomNumber: roomNumber,
      );
      await scheduleService.updateSchedule(id, entry);
      await loadSchedules(); // Recharger la liste
      AppNotification.showSuccess('Emploi du temps mis à jour avec succès');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSchedule(int id) async {
    try {
      isLoading.value = true;
      await scheduleService.deleteSchedule(id);
      schedules.removeWhere((entry) => entry.id == id);
      AppNotification.showSuccess('Emploi du temps supprimé avec succès');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
