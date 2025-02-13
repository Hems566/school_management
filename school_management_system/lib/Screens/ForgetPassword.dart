import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/Widgets/PageWrapper.dart';
import 'package:school_management/controllers/auth_controller.dart';
import 'package:school_management/utils/app_notification.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _authController.forgotPassword(_emailController.text);
        AppNotification.showSuccess(
            'Un email de réinitialisation a été envoyé à votre adresse email.');
        Get.back();
      } catch (error) {
        AppNotification.showError(error.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: "Mot de passe oublié",
      showDrawer: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Entrez votre adresse email pour recevoir un lien de réinitialisation',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 32.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse email';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Veuillez entrer une adresse email valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              Obx(() => ElevatedButton(
                    onPressed:
                        _authController.isLoading.value ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                    ),
                    child: _authController.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Envoyer le lien',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                  )),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Retour à la connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
