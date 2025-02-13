import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_schedule_controller.dart';
import '../../Widgets/PageWrapper.dart';
import '../../Widgets/SchedulePainter.dart';

class UserScheduleScreen extends GetView<UserScheduleController> {
  const UserScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Mon emploi du temps',
      showDrawer: true,
      child: Obx(() {
        if (controller.status.value == ScheduleStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.status.value == ScheduleStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.loadSchedule,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (controller.schedules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Aucun cours planifié',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
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
