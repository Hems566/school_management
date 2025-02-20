import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';
import '../services/UserModel.dart';
import '../routes/app_routes.dart';

class HomeController extends GetxController {
  Timer? _refreshTimer;
  final AuthService _authService;
  final DashboardService _dashboardService;

  HomeController({
    required AuthService authService,
    required DashboardService dashboardService,
  })  : _authService = authService,
        _dashboardService = dashboardService;

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  // Dashboard data
  final RxInt totalStudents = 0.obs;
  final RxInt totalTeachers = 0.obs;
  final RxInt pendingRequests = 0.obs;
  final RxList<Map<String, dynamic>> recentActivities =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserDetails();
    loadDashboardData();

    // Rafraîchir les données quand l'utilisateur change
    ever(currentUser, (_) => loadDashboardData());

    // Rafraîchir les données périodiquement
    _refreshTimer =
        Timer.periodic(const Duration(minutes: 5), (_) => loadDashboardData());
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // Charger les données du dashboard
      final dashboardData = await _dashboardService.getDashboardData();
      print('Dashboard Data received: $dashboardData');

      if (dashboardData is Map<String, dynamic>) {
        totalStudents.value = dashboardData['totalStudents'] as int? ?? 0;
        totalTeachers.value = dashboardData['totalTeachers'] as int? ?? 0;
        pendingRequests.value = dashboardData['pendingRequests'] as int? ?? 0;

        print(
            'Stats updated: Students=${totalStudents.value}, Teachers=${totalTeachers.value}, Pending=${pendingRequests.value}');
      } else {
        print('Invalid dashboard data format');
      }

      // Charger les activités récentes
      final activities = await _dashboardService.getRecentActivities();
      print('Activities received: $activities');

      if (activities.isEmpty) {
        print('No activities found');
      } else {
        print('Found ${activities.length} activities');
      }

      recentActivities.clear();
      recentActivities.addAll(activities);
      print('Activities updated: ${recentActivities.length} items');
    } catch (e) {
      print('Error loading dashboard data: $e');
      final message = e.toString().contains('Connection refused')
          ? 'Impossible de se connecter au serveur'
          : 'Erreur lors du chargement des données';
      Get.snackbar(
        'Erreur',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserDetails() async {
    try {
      isLoading.value = true;
      final userDetails = await _authService.getUserDetails();
      currentUser.value = userDetails;
      errorMessage.value = null;
    } catch (e) {
      print('Error loading user details: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadUserDetails();
    await loadDashboardData();
  }

  void logout() async {
    try {
      await _authService.logout();
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      print('Error during logout: $e');
      errorMessage.value = e.toString();
    }
  }

  // Getters pour faciliter l'accès aux informations de l'utilisateur
  String get userName =>
      currentUser.value?.name ??
      currentUser.value?.email.split('@').first ??
      '';
  String get userEmail => currentUser.value?.email ?? '';
  String get rollNumber => currentUser.value?.rollNumber ?? '';
  String get className => currentUser.value?.className ?? '';
  String get section => currentUser.value?.section ?? '';
}
