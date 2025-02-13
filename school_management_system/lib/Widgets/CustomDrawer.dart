import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/controllers/auth_controller.dart';
import 'package:school_management/controllers/home_controller.dart';
import 'package:school_management/routes/app_routes.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    final AuthController authController = Get.find<AuthController>();

    return Drawer(
      child: Obx(() {
        final user = homeController.currentUser.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(homeController.userName),
              accountEmail: Text(homeController.userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user.initials,
                  style: const TextStyle(fontSize: 24.0, color: Colors.black87),
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                if (user.role == 'admin') {
                  Get.offAllNamed(AppRoutes.adminDashboard);
                } else {
                  Get.offAllNamed(AppRoutes.home);
                }
              },
            ),
            if (user.role == 'admin') ...[
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Enseignants'),
                onTap: () => Get.toNamed(AppRoutes.adminTeachers),
              ),
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text('Matières'),
                onTap: () => Get.toNamed(AppRoutes.adminSubjects),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Emplois du temps'),
                onTap: () => Get.toNamed(AppRoutes.adminSchedule),
              ),
            ],
            if (user.role == 'teacher') ...[
              ListTile(
                leading: const Icon(Icons.assessment),
                title: const Text('Gestion des résultats'),
                onTap: () => Get.toNamed(AppRoutes.teacherResults),
              ),
            ],
            if (user.role == 'student') ...[
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Mes résultats'),
                onTap: () => Get.toNamed(AppRoutes.studentResults),
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () async {
                await authController.logout();
              },
            ),
          ],
        );
      }),
    );
  }
}
