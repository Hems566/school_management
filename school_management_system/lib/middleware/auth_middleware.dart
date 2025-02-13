import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/controllers/auth_controller.dart';
import 'package:school_management/routes/app_routes.dart';

class AuthGuard extends GetMiddleware {
  AuthGuard() {
    print('AuthGuard initialized');
  }

  @override
  RouteSettings? redirect(String? route) {
    try {
      print('AuthGuard checking route: $route');
      final authController = Get.find<AuthController>();
      print(
          'AuthGuard found AuthController, isLoggedIn: ${authController.isLoggedIn.value}');

      if (!authController.isLoggedIn.value && route != AppRoutes.login) {
        return const RouteSettings(name: AppRoutes.login);
      }
      return null;
    } catch (e) {
      print('AuthGuard error: $e');
      return const RouteSettings(name: AppRoutes.login);
    }
  }
}

class AdminGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();

      if (!authController.isLoggedIn.value) {
        return const RouteSettings(name: AppRoutes.login);
      }

      if (authController.currentUser.value?.role != 'admin') {
        return const RouteSettings(name: AppRoutes.home);
      }

      return null;
    } catch (e) {
      print('AdminGuard error: $e');
      return const RouteSettings(name: AppRoutes.login);
    }
  }
}

class TeacherGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();

      if (!authController.isLoggedIn.value) {
        return const RouteSettings(name: AppRoutes.login);
      }

      final userRole = authController.currentUser.value?.role;
      if (userRole != 'teacher' && userRole != 'admin') {
        return const RouteSettings(name: AppRoutes.home);
      }

      return null;
    } catch (e) {
      print('TeacherGuard error: $e');
      return const RouteSettings(name: AppRoutes.login);
    }
  }
}

class StudentGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();

      if (!authController.isLoggedIn.value) {
        return const RouteSettings(name: AppRoutes.login);
      }

      final userRole = authController.currentUser.value?.role;
      if (userRole != 'student' && userRole != 'admin') {
        return const RouteSettings(name: AppRoutes.home);
      }

      return null;
    } catch (e) {
      print('StudentGuard error: $e');
      return const RouteSettings(name: AppRoutes.login);
    }
  }
}

class GuestGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();

      if (authController.isLoggedIn.value) {
        final userRole = authController.currentUser.value?.role;
        if (userRole == 'admin') {
          return const RouteSettings(name: AppRoutes.adminDashboard);
        }
        return const RouteSettings(name: AppRoutes.home);
      }
      return null;
    } catch (e) {
      print('GuestGuard error: $e');
      return null;
    }
  }
}
