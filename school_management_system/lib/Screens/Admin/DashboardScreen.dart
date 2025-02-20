import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/teacher_controller.dart';
import '../../controllers/subject_controller.dart';
import '../../Widgets/PageWrapper.dart';

class DashboardScreen extends GetView<HomeController> {
  final TeacherController teacherController = Get.find<TeacherController>();
  final SubjectController subjectController = Get.find<SubjectController>();

  DashboardScreen({Key? key}) : super(key: key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Tableau de bord',
      showDrawer: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            controller.refreshData();
            Get.snackbar(
              'Mise à jour',
              'Actualisation des données en cours...',
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 2),
            );
          },
        ),
      ],
      child: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistiques générales',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      Obx(() => StatisticCard(
                            title: 'Total Enseignants',
                            value: '${teacherController.teachers.length}',
                            icon: Icons.people,
                            color: Colors.blue,
                          )),
                      Obx(() => StatisticCard(
                            title: 'Total Étudiants',
                            value: '${controller.totalStudents}',
                            icon: Icons.school,
                            color: Colors.orange,
                          )),
                      Obx(() => StatisticCard(
                            title: 'Matières',
                            value: '${subjectController.subjects.length}',
                            icon: Icons.book,
                            color: Colors.green,
                          )),
                      Obx(() => StatisticCard(
                            title: 'Demandes en attente',
                            value: '${controller.pendingRequests}',
                            icon: Icons.pending_actions,
                            color: Colors.red,
                          )),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Taux de présence',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2,
                    children: const [
                      AttendanceCard(
                        title: 'Présence Enseignants',
                        percentage: 0.95,
                      ),
                      AttendanceCard(
                        title: 'Présence Étudiants',
                        percentage: 0.88,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Activités Récentes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Affichage des activités récentes
                  Obx(() => controller.recentActivities.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'Aucune activité récente',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                      : RecentActivitiesList(
                          activities: controller.recentActivities.toList(),
                        )),
                ],
              ),
            )),
    );
  }
}

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatisticCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final String title;
  final double percentage;

  const AttendanceCard({
    Key? key,
    required this.title,
    required this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const Spacer(),
            LinearPercentIndicator(
              percent: percentage,
              lineHeight: 8,
              backgroundColor: Colors.grey[800],
              progressColor: Colors.blue,
              barRadius: const Radius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentActivitiesList extends StatelessWidget {
  static IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'person_add':
        return Icons.person_add;
      case 'book':
        return Icons.book;
      case 'calendar_today':
        return Icons.calendar_today;
      default:
        return Icons.info;
    }
  }

  static Color _getColor(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  final List<Map<String, dynamic>> activities;

  const RecentActivitiesList({
    Key? key,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activities.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final activity = activities[index];
            try {
              return ActivityItem(
                title: activity['title'] as String? ?? '',
                description: activity['description'] as String? ?? '',
                time: activity['time'] as String? ?? '',
                icon: _getIconData(activity['icon'] as String? ?? 'info'),
                color: _getColor(activity['color'] as String? ?? 'grey'),
              );
            } catch (e) {
              print('Error building activity item: $e for activity: $activity');
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;

  const ActivityItem({
    Key? key,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
