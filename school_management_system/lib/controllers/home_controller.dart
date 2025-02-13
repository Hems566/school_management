import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/UserModel.dart';
import '../routes/app_routes.dart';

class HomeController extends GetxController {
  final AuthService _authService;

  HomeController({required AuthService authService})
      : _authService = authService;

  final isLoading = true.obs;
  final errorMessage = RxnString();

  // User details
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    loadUserDetails();
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

  Future<void> refreshData() async {
    await loadUserDetails();
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
