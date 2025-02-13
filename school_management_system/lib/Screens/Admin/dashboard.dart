import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/Widgets/PageWrapper.dart';
import 'package:school_management/controllers/auth_controller.dart';
import 'package:school_management/routes/app_routes.dart';

class AdminDashboard extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  AdminDashboard({super.key});

  Widget _buildCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.green,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Tableau de bord administrateur',
      showDrawer: true,
      child: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildCard(
            title: 'Gestion des Enseignants',
            icon: Icons.people,
            onTap: () => Get.toNamed(AppRoutes.adminTeachers),
          ),
          _buildCard(
            title: 'Gestion des Matières',
            icon: Icons.book,
            onTap: () => Get.toNamed(AppRoutes.adminSubjects),
          ),
          _buildCard(
            title: 'Emploi du Temps',
            icon: Icons.calendar_today,
            onTap: () => Get.toNamed(AppRoutes.adminSchedule),
          ),
          _buildCard(
            title: 'Résultats d\'examens',
            icon: Icons.assessment,
            onTap: () => Get.toNamed(AppRoutes.examResults),
          ),
        ],
      ),
    );
  }
}
