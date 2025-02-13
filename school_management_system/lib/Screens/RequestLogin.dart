import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:get/get.dart';
import 'package:school_management/Widgets/BouncingButton.dart';
import 'package:school_management/Widgets/PageWrapper.dart';
import 'package:school_management/controllers/request_login_controller.dart';
import 'package:school_management/utils/app_notification.dart';

class RequestLogin extends GetView<RequestLoginController> {
  const RequestLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return PageWrapper(
      title: "Demande d'inscription",
      showDrawer: false,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              buildTextField(
                transform: width,
                label: "Nom",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  RegExp nameRegExp = RegExp(r'^[a-zA-Z ]+$');
                  if (!nameRegExp.hasMatch(value)) {
                    return 'Veuillez entrer un nom valide';
                  }
                  return null;
                },
                onSaved: (val) => controller.name.value = val ?? '',
              ),
              const SizedBox(height: 20),
              buildTextField(
                transform: width,
                label: "Numéro d'étudiant",
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Veuillez entrer votre numéro d\'étudiant';
                  }
                  return null;
                },
                onSaved: (val) => controller.rollno.value = val ?? '',
              ),
              const SizedBox(height: 20),
              Transform(
                transform: Matrix4.translationValues(0, 0, 0),
                child: Obx(() => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Classe",
                        labelStyle: TextStyle(color: Colors.black87),
                        border: OutlineInputBorder(),
                      ),
                      value: controller.selectedClass.value.isEmpty
                          ? null
                          : controller.selectedClass.value,
                      items: RequestLoginController.validTracks
                          .map((track) => DropdownMenuItem<String>(
                                value: track,
                                child: Text(track),
                              ))
                          .toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner votre classe';
                        }
                        return null;
                      },
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.selectedClass.value = newValue;
                        }
                      },
                    )),
              ),
              const SizedBox(height: 20),
              buildTextField(
                transform: width,
                label: "Email",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!EmailValidator.validate(value)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
                onSaved: (val) => controller.email.value = val ?? '',
              ),
              const SizedBox(height: 20),
              buildTextField(
                transform: width,
                label: "Téléphone",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  String pattern = r'(^(?:[+0]9)?[0-9]{8}$)';
                  RegExp regExp = RegExp(pattern);
                  if (!regExp.hasMatch(value)) {
                    return 'Veuillez entrer un numéro valide';
                  }
                  return null;
                },
                onSaved: (val) => controller.phno.value = val ?? '',
              ),
              const SizedBox(height: 30),
              Transform(
                transform: Matrix4.translationValues(0, 0, 0),
                child: Obx(() => Bouncing(
                      onPress: controller.isLoading.value
                          ? null
                          : controller.register,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 48,
                        decoration: BoxDecoration(
                          color: controller.isLoading.value
                              ? Colors.grey
                              : Colors.green,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Demander",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required double transform,
    required String label,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return Transform(
      transform: Matrix4.translationValues(0, 0, 0),
      child: TextFormField(
        validator: validator,
        onSaved: onSaved,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
