import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/controllers/auth_controller.dart';
import 'package:school_management/routes/app_routes.dart';

class MainDrawer extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userRole = _authController.currentUser.value?.role;
    final userName = _authController.currentUser.value?.name ?? "";
    final userEmail = _authController.currentUser.value?.email ?? "";

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : "?",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.home_outlined,
                      title: "Accueil",
                      onTap: () => Get.toNamed(AppRoutes.home),
                    ),
                    if (userRole == 'student') ...[
                      _buildMenuItem(
                        context,
                        icon: Icons.calendar_month_outlined,
                        title: "Mon emploi du temps",
                        onTap: () => Get.toNamed(AppRoutes.studentSchedule),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.school_outlined,
                        title: "Mes résultats",
                        onTap: () => Get.toNamed(AppRoutes.studentResults),
                      ),
                    ],
                    if (userRole == 'teacher') ...[
                      _buildMenuItem(
                        context,
                        icon: Icons.calendar_month_outlined,
                        title: "Mon emploi du temps",
                        onTap: () => Get.toNamed(AppRoutes.teacherSchedule),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.school_outlined,
                        title: "Résultats d'examens",
                        onTap: () => Get.toNamed(AppRoutes.teacherResults),
                      ),
                    ],
                    if (userRole == 'admin') ...[
                      _buildMenuItem(
                        context,
                        icon: Icons.calendar_month_outlined,
                        title: "Gestion des emplois du temps",
                        onTap: () => Get.toNamed(AppRoutes.adminSchedule),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.school_outlined,
                        title: "Gestion des examens",
                        onTap: () => Get.toNamed(AppRoutes.examResults),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.people_outline,
                        title: "Gestion des enseignants",
                        onTap: () => Get.toNamed(AppRoutes.adminTeachers),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.book_outlined,
                        title: "Gestion des matières",
                        onTap: () => Get.toNamed(AppRoutes.adminSubjects),
                      ),
                    ],
                    _buildMenuItem(
                      context,
                      icon: Icons.person_outline,
                      title: "Mon profil",
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: "Notifications",
                      onTap: () {},
                    ),
                    const Divider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.logout,
                      title: "Déconnexion",
                      onTap: () => _authController.logout(),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? Theme.of(context).primaryColor,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
