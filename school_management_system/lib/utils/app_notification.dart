import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppNotification {
  static void showSuccess(String message) {
    Get.snackbar(
      'Succès',
      message,
      colorText: Colors.white,
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'Erreur',
      message,
      colorText: Colors.white,
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  static void showWarning(String message) {
    Get.snackbar(
      'Attention',
      message,
      colorText: Colors.black,
      backgroundColor: Colors.amber,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfo(String message) {
    Get.snackbar(
      'Information',
      message,
      colorText: Colors.white,
      backgroundColor: Colors.blue,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}
