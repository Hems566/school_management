import 'package:get/get.dart';
import '../services/auth_service.dart';

class ForgetPasswordController extends GetxController {
  final AuthService _authService = AuthService();
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final isSuccess = false.obs;

  Future<void> requestResetCode(String email) async {
    try {
      isLoading.value = true;
      await _authService.forgotPassword(email);
      isSuccess.value = true;
      errorMessage.value = null;
    } catch (e) {
      errorMessage.value = e.toString();
      isSuccess.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String resetCode, String newPassword) async {
    try {
      isLoading.value = true;
      await _authService.resetPassword(resetCode, newPassword);
      isSuccess.value = true;
      errorMessage.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      errorMessage.value = e.toString();
      isSuccess.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}
