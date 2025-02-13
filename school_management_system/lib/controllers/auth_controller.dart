import 'package:get/get.dart';
import 'package:school_management/services/auth_service.dart';
import 'package:school_management/services/UserModel.dart';
import 'package:school_management/utils/app_notification.dart';
import 'package:school_management/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService;

  AuthController({required AuthService authService})
      : _authService = authService;

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final RxBool isLoggedIn = false.obs;
  bool get isAdmin => currentUser.value?.role == 'admin' ?? false;
  bool get isTeacher => currentUser.value?.role == 'teacher' ?? false;
  bool get isStudent => currentUser.value?.role == 'student' ?? false;

  @override
  void onInit() {
    super.onInit();
    checkAuth();
    ever(currentUser, (user) {
      isLoggedIn.value = user != null;
      if (user != null) {
        _redirectBasedOnRole(user.role);
      }
    });
  }

  void _redirectBasedOnRole(String role) {
    switch (role) {
      case 'admin':
        Get.offAllNamed(AppRoutes.adminDashboard);
        break;
      case 'teacher':
        Get.offAllNamed(AppRoutes.teacherResults);
        break;
      case 'student':
        Get.offAllNamed(AppRoutes.studentResults);
        break;
      default:
        Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';
      currentUser.value = await _authService.login(email, password);
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authService.logout();
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkAuth() async {
    try {
      isLoading.value = true;
      error.value = '';
      final userData = await _authService.getUserDetails();
      if (userData != null) {
        currentUser.value = userData;
      }
    } catch (e) {
      print('Auth check error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<UserModel>> getTeachers() async {
    try {
      isLoading.value = true;
      error.value = '';
      return await _authService.getTeachers();
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(
          'Erreur lors du chargement des enseignants: ${e.toString()}');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> getRegistrationRequests() async {
    try {
      isLoading.value = true;
      error.value = '';
      return await _authService.getRegistrationRequests();
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(
          'Erreur lors du chargement des demandes: ${e.toString()}');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveRegistration(int requestId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authService.approveRegistration(requestId);
      AppNotification.showSuccess('Demande approuvée avec succès');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectRegistration(int requestId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authService.rejectRegistration(requestId);
      AppNotification.showSuccess('Demande rejetée');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> requestLogin({
    required String email,
    required String name,
    required String rollNumber,
    required String className,
    required String phoneNumber,
    String? role,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      return await _authService.register(
        email: email,
        name: name,
        rollNumber: rollNumber,
        className: className,
        phoneNumber: phoneNumber,
        role: role,
      );
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authService.forgotPassword(email);
      AppNotification.showSuccess(
          'Instructions de réinitialisation envoyées à votre email');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authService.resetPassword(token, newPassword);
      AppNotification.showSuccess('Mot de passe réinitialisé avec succès');
    } catch (e) {
      error.value = e.toString();
      AppNotification.showError(e.toString());
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
