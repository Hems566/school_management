import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/schedule_controller.dart';
import '../../Widgets/SchedulePainter.dart';
import '../../Widgets/PageWrapper.dart';
import '../../services/UserModel.dart';
import '../../services/auth_service.dart';

class TeacherScheduleScreen extends GetView<ScheduleController> {
  TeacherScheduleScreen({Key? key}) : super(key: key) {
    final user = Get.find<AuthService>().currentUser;
    if (user != null) {
      controller.loadTeacherSchedule(user.id);
    } else {
      Get.back(); // Retour à l'écran précédent si pas d'utilisateur
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Mon emploi du temps',
      showDrawer: true,
      child: Obx(() {
        final user = Get.find<AuthService>().currentUser;
        if (user == null) {
          return const Center(child: Text('Utilisateur non connecté'));
        }

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.error.value),
                ElevatedButton(
                  onPressed: () => controller.loadTeacherSchedule(user.id),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (controller.schedules.isEmpty) {
          return const Center(
            child: Text('Aucun cours planifié'),
          );
        }

        return SchedulePainter(
          schedules: controller.schedules,
          isAdmin: false,
        );
      }),
    );
  }
}
