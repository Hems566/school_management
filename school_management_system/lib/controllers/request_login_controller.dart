import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/services/auth_service.dart';
import 'package:school_management/utils/app_notification.dart';

class RequestLoginController extends GetxController {
  final AuthService _authService;
  final formKey = GlobalKey<FormState>();

  RequestLoginController({required AuthService authService})
      : _authService = authService;

  final RxBool isLoading = false.obs;
  final RxString name = ''.obs;
  final RxString rollno = ''.obs;
  final RxString selectedClass = ''.obs;
  final RxString email = ''.obs;
  final RxString phno = ''.obs;

  static const List<String> validTracks = [
    'Réseaux et Systèmes Communicants',
    'Systèmes Informations'
  ];

  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      try {
        isLoading.value = true;

        final result = await _authService.register(
          email: email.value,
          name: name.value,
          rollNumber: rollno.value,
          className: selectedClass.value,
          phoneNumber: phno.value,
        );

        AppNotification.showSuccess(
          "Demande d'inscription envoyée, vous receverez vos identifiants par email.",
        );

        Get.offAllNamed('/login');
      } catch (e, stackTrace) {
        AppNotification.showError(
            'Impossible de soumettre votre demande d\'inscription. Veuillez réessayer plus tard.');
      } finally {
        isLoading.value = false;
      }
    }
  }
}
