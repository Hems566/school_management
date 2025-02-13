import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/schedule_controller.dart';
import '../../Widgets/SchedulePainter.dart';
import '../../Widgets/PageWrapper.dart';
import '../../services/UserModel.dart';
import '../../services/auth_service.dart';

class StudentScheduleScreen extends GetView<ScheduleController> {
  StudentScheduleScreen({Key? key}) : super(key: key) {
    final user = Get.find<AuthService>().currentUser;
    if (user != null && user.className != null) {
      controller.loadClassSchedule(user.className!);
    } else {
      Get.back(); // Retour à l'écran précédent si pas d'utilisateur ou pas de classe
      Get.snackbar(
        'Erreur',
        'Aucune classe assignée à cet étudiant',
        snackPosition: SnackPosition.BOTTOM,
      );
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
                  onPressed: () => user.className != null
                      ? controller.loadClassSchedule(user.className!)
                      : null,
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

        return Column(
          children: [
            if (user.className != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Classe: ${user.className}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            Expanded(
              child: SchedulePainter(
                schedules: controller.schedules,
                isAdmin: false,
              ),
            ),
          ],
        );
      }),
    );
  }
}
