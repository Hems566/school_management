import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/controllers/auth_controller.dart';

class AuthGuard extends GetMiddleware {
  final authController = Get.find<AuthController>();

  @override
  RouteSettings? redirect(String? route) {
    if (authController.isLoggedIn.value) {
      // Si l'utilisateur est déjà connecté et essaie d'accéder à la page de connexion
      if (route == '/login' ||
          route == '/forget-password' ||
          route == '/request-login') {
        return const RouteSettings(name: '/home');
      }
      return null;
    } else {
      // Si l'utilisateur n'est pas connecté et essaie d'accéder à une page protégée
      if (route != '/login' &&
          route != '/forget-password' &&
          route != '/request-login') {
        return const RouteSettings(name: '/login');
      }
      return null;
    }
  }
}

class AdminGuard extends GetMiddleware {
  final authController = Get.find<AuthController>();

  @override
  RouteSettings? redirect(String? route) {
    if (!authController.isLoggedIn.value) {
      return const RouteSettings(name: '/login');
    }

    final user = authController.currentUser.value;
    if (user == null || user.role != 'admin') {
      Get.snackbar(
        'Accès refusé',
        'Vous n\'avez pas les permissions nécessaires',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return const RouteSettings(name: '/home');
    }
    return null;
  }
}

class TeacherGuard extends GetMiddleware {
  final authController = Get.find<AuthController>();

  @override
  RouteSettings? redirect(String? route) {
    if (!authController.isLoggedIn.value) {
      return const RouteSettings(name: '/login');
    }

    final userRole = authController.currentUser.value?.role;
    if (userRole != 'admin' && userRole != 'teacher') {
      Get.snackbar(
        'Accès refusé',
        'Vous n\'avez pas les permissions nécessaires',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return const RouteSettings(name: '/home');
    }
    return null;
  }
}

class StudentGuard extends GetMiddleware {
  final authController = Get.find<AuthController>();

  @override
  RouteSettings? redirect(String? route) {
    if (!authController.isLoggedIn.value) {
      return const RouteSettings(name: '/login');
    }

    final userRole = authController.currentUser.value?.role;
    if (userRole != 'admin' && userRole != 'student') {
      Get.snackbar(
        'Accès refusé',
        'Vous n\'avez pas les permissions nécessaires',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return const RouteSettings(name: '/home');
    }
    return null;
  }
}
