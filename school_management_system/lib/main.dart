import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uni_links/uni_links.dart';
import 'package:school_management/bindings/app_binding.dart';
import 'package:school_management/routes/app_routes.dart';
import 'package:school_management/services/auth_service.dart';
import 'package:school_management/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration du deep linking
  try {
    // Gérer le lien initial
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      print('Lien initial: $initialUri');
      if (initialUri.path == '/reset-password') {
        final token = initialUri.queryParameters['token'];
        if (token != null) {
          print('Token de réinitialisation trouvé: $token');
          Get.toNamed('/reset-password', parameters: {'token': token});
        }
      }
    }

    // Écouter les liens entrants
    uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.path == '/reset-password') {
        final token = uri.queryParameters['token'];
        if (token != null) {
          print('Nouveau lien de réinitialisation reçu avec token: $token');
          Get.toNamed('/reset-password', parameters: {'token': token});
        }
      }
    }, onError: (err) {
      print('Erreur de deep linking: $err');
    });
  } catch (e) {
    print('Erreur lors de l\'initialisation du deep linking: $e');
  }

  try {
    print('Initialisation de l\'application...');

    // Enregistrer les services essentiels
    final authService = AuthService();
    Get.put<AuthService>(authService, permanent: true);
    print('AuthService enregistré');

    // Enregistrer le contrôleur d'authentification
    final authController = AuthController(authService: authService);
    Get.put<AuthController>(authController, permanent: true);
    print('AuthController enregistré');

    // Initialiser les autres dépendances
    final binding = AppBinding();
    binding.dependencies();
    print('Dépendances initialisées');

    await authController.checkAuth();
    print('État d\'authentification vérifié');

    print('Initialisation terminée');
  } catch (e) {
    print('Erreur lors de l\'initialisation: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  String _getInitialRoute() {
    // Vérifier si nous avons un token de réinitialisation dans les paramètres
    final parameters = Get.parameters;
    if (parameters.containsKey('token')) {
      return '/reset-password';
    }

    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn.value) {
      return AppRoutes.login;
    }

    final role = authController.currentUser.value?.role;
    switch (role) {
      case 'admin':
        return AppRoutes.adminDashboard;
      case 'teacher':
        print('Redirection enseignant vers son emploi du temps');
        return AppRoutes.teacherSchedule;
      case 'student':
        print('Redirection étudiant vers son emploi du temps');
        return AppRoutes.studentSchedule;
      default:
        return AppRoutes.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'School Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: _getInitialRoute(),
      getPages: AppRoutes.pages,
      defaultTransition: Transition.fadeIn,
      routingCallback: (routing) {
        if (routing == null) return;

        print('Navigation vers: ${routing.current}');
        final authController = Get.find<AuthController>();

        // Permettre l'accès à la page de réinitialisation sans authentification
        if (routing.current.startsWith('/reset-password')) {
          return;
        }

        // Si l'utilisateur est connecté et essaie d'accéder à la page de login
        if (routing.current == AppRoutes.login &&
            authController.isLoggedIn.value) {
          print('Utilisateur déjà connecté, redirection vers l\'accueil');
          Get.offAllNamed(_getInitialRoute());
          return;
        }

        // Si l'utilisateur n'est pas connecté et essaie d'accéder à une page protégée
        if (!routing.current.startsWith('/login') &&
            !routing.current.startsWith('/request-login') &&
            !routing.current.startsWith('/forgot-password') &&
            !authController.isLoggedIn.value) {
          print('Utilisateur non connecté, redirection vers login');
          Get.offAllNamed(AppRoutes.login);
          return;
        }

        // Vérifier les permissions selon le rôle
        if (authController.isLoggedIn.value) {
          final role = authController.currentUser.value?.role;
          final currentRoute = routing.current;

          if (role == 'student' && currentRoute.startsWith('/teacher')) {
            print('Étudiant essayant d\'accéder à une page enseignant');
            Get.back();
          } else if (role == 'teacher' && currentRoute.startsWith('/student')) {
            print('Enseignant essayant d\'accéder à une page étudiant');
            Get.back();
          }
        }
      },
    );
  }
}
