import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../middleware/auth_middleware.dart';
import 'package:school_management/Screens/Admin/dashboard.dart';
import 'package:school_management/Screens/Admin/subjects.dart';
import 'package:school_management/Screens/Admin/teachers.dart';
import 'package:school_management/Screens/Admin/schedule.dart';
import 'package:school_management/Screens/ExamResults/ExamResultsScreen.dart';
import 'package:school_management/Screens/ExamResults/teacher_results.dart';
import 'package:school_management/Screens/ExamResults/student_results.dart';
import 'package:school_management/Screens/ForgetPassword.dart';
import 'package:school_management/Screens/home.dart';
import 'package:school_management/Screens/LoginPage.dart';
import 'package:school_management/Screens/RequestLogin.dart';
import 'package:school_management/Screens/ResetPassword.dart';

import '../Screens/Schedule/AdminScheduleScreen.dart';
import '../Screens/Schedule/UserScheduleScreen.dart';
import '../bindings/user_schedule_binding.dart';

class AppRoutes {
  // Routes pour l'emploi du temps
  static const String adminSchedule = '/admin/schedule';
  static const String teacherSchedule = '/teacher/schedule';
  static const String studentSchedule = '/student/schedule';

  // Routes publiques
  static const String login = '/login';
  static const String requestLogin = '/request-login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Routes protégées par authentification
  static const String home = '/home';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminTeachers = '/admin/teachers';
  static const String adminSubjects = '/admin/subjects';
  static const String examResults = '/exam-results';
  static const String teacherResults = '/teacher/results';
  static const String studentResults = '/student/results';

  // Middlewares de sécurité
  static final guestGuard = [GuestGuard()];
  static final authGuard = [AuthGuard()];
  static final adminGuard = [AuthGuard(), AdminGuard()];
  static final teacherGuard = [AuthGuard(), TeacherGuard()];
  static final studentGuard = [AuthGuard(), StudentGuard()];

  static final pages = [
    // Pages des emplois du temps
    GetPage(
      name: adminSchedule,
      page: () => AdminScheduleScreen(),
      middlewares: adminGuard,
    ),
    GetPage(
      name: teacherSchedule,
      page: () => const UserScheduleScreen(),
      binding: UserScheduleBinding(),
      middlewares: teacherGuard,
    ),
    GetPage(
      name: studentSchedule,
      page: () => const UserScheduleScreen(),
      binding: UserScheduleBinding(),
      middlewares: studentGuard,
    ),
    // Pages publiques
    GetPage(
      name: login,
      page: () => const MyHomePage(),
      middlewares: guestGuard,
    ),
    GetPage(
      name: requestLogin,
      page: () => const RequestLogin(),
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPassword(),
    ),
    GetPage(
      name: resetPassword,
      page: () => const ResetPassword(),
      preventDuplicates: false, // Permet d'ouvrir même si déjà dans la pile
      transition: Transition.fade,
      middlewares: [], // Pas de middleware pour permettre l'accès direct
    ),

    // Pages protégées
    GetPage(
      name: home,
      page: () => const Home(),
      middlewares: authGuard,
    ),

    // Pages admin
    GetPage(
      name: adminDashboard,
      page: () => AdminDashboard(),
      middlewares: adminGuard,
    ),
    GetPage(
      name: adminTeachers,
      page: () => TeachersManagementPage(),
      middlewares: adminGuard,
    ),
    GetPage(
      name: adminSubjects,
      page: () => SubjectsPage(),
      middlewares: adminGuard,
    ),

    // Pages de résultats
    GetPage(
      name: examResults,
      page: () => ExamResultsScreen(),
      middlewares: authGuard,
    ),
    GetPage(
      name: teacherResults,
      page: () => TeacherResultsPage(),
      middlewares: teacherGuard,
    ),
    GetPage(
      name: studentResults,
      page: () => StudentResultsPage(),
      middlewares: studentGuard,
    ),
  ];
}
