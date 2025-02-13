import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:school_management/Widgets/BouncingButton.dart';
import 'package:school_management/Widgets/PageWrapper.dart';
import 'package:school_management/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:school_management/routes/app_routes.dart';
import 'package:school_management/utils/app_notification.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late Animation<double> delayedAnimation;
  late Animation<double> muchDelayedAnimation;
  late Animation<double> LeftCurve;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    // Vérifier si l'utilisateur est déjà connecté
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Get.find<AuthController>();
      if (authController.isLoggedIn.value) {
        _redirectBasedOnRole(authController);
      }
    });

    // Initialiser les animations
    animationController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);
    animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));
    delayedAnimation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn)));
    muchDelayedAnimation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.8, 1.0, curve: Curves.fastOutSlowIn)));
    LeftCurve = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)));

    animationController.forward();
  }

  void _redirectBasedOnRole(AuthController authController) {
    if (authController.isAdmin) {
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else if (authController.isTeacher) {
      Get.offAllNamed(AppRoutes.teacherResults);
    } else if (authController.isStudent) {
      Get.offAllNamed(AppRoutes.studentResults);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool passshow = false;
  String? _pass;
  String? _email;
  final AuthController _authController = Get.find<AuthController>();

  Future<void> _handleLogin() async {
    if (!_formkey.currentState!.validate()) {
      setState(() => _autoValidate = true);
      return;
    }

    _formkey.currentState!.save();

    try {
      await _authController.login(_email ?? '', _pass ?? '');
      // La redirection est gérée par le contrôleur d'authentification
    } catch (e) {
      AppNotification.showError('Erreur de connexion: ${e.toString()}');
      setState(() => _autoValidate = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget? _) {
        return PageWrapper(
          title: "Login",
          showDrawer: false,
          automaticallyImplyLeading: false,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Transform(
                  transform: Matrix4.translationValues(
                      animation.value * width, 0.0, 0.0),
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        const Text(
                          'Hello',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(30.0, 35.0, 0, 0),
                          child: Text(
                            'There',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 40.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(135.0, 0.0, 0, 30),
                          child: Text(
                            '.',
                            style: TextStyle(
                                color: Colors.green[400],
                                fontSize: 80.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 10, 30, 10),
                child: Transform(
                  transform:
                      Matrix4.translationValues(LeftCurve.value * width, 0, 0),
                  child: Form(
                    key: _formkey,
                    autovalidateMode: _autoValidate
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez entrer votre email";
                            }
                            if (!EmailValidator.validate(value)) {
                              return "Veuillez entrer un email valide";
                            }
                            return null;
                          },
                          onSaved: (value) => _email = value,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'EMAIL',
                            contentPadding: EdgeInsets.all(5),
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          obscuringCharacter: '*',
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Veuillez entrer votre mot de passe";
                            }
                            return null;
                          },
                          onSaved: (val) => _pass = val,
                          decoration: InputDecoration(
                            suffix: IconButton(
                              onPressed: () =>
                                  setState(() => passshow = !passshow),
                              icon:
                                  Icon(passshow ? Icons.lock_open : Icons.lock),
                            ),
                            labelText: 'MOT DE PASSE',
                            contentPadding: const EdgeInsets.all(5),
                            labelStyle: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey),
                            focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green)),
                          ),
                          obscureText: !passshow,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 10, 30, 10),
                child: Transform(
                  transform: Matrix4.translationValues(
                      delayedAnimation.value * width, 0, 0),
                  child: Container(
                    alignment: const Alignment(1.0, 0),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, right: 20.0),
                      child: Bouncing(
                        onPress: () => Get.toNamed(AppRoutes.forgotPassword),
                        child: const Text(
                          "Mot de passe oublié ?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 5, 20.0, 5),
                child: Transform(
                  transform: Matrix4.translationValues(
                      muchDelayedAnimation.value * width, 0, 0),
                  child: Column(
                    children: <Widget>[
                      Obx(() => MaterialButton(
                            onPressed: _authController.isLoading.value
                                ? null
                                : _handleLogin,
                            elevation: 0.0,
                            height: 50,
                            minWidth: MediaQuery.of(context).size.width,
                            color: Colors.green,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                                    "Se connecter",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          )),
                      const SizedBox(height: 20.0),
                      MaterialButton(
                        onPressed: () => Get.toNamed(AppRoutes.requestLogin),
                        elevation: 0.5,
                        height: 50,
                        minWidth: MediaQuery.of(context).size.width,
                        color: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_add,
                              color: Colors.black87,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Demander un identifiant',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        );
      },
    );
  }
}
