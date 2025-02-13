import 'package:get/get.dart';
import '../controllers/user_schedule_controller.dart';
import '../services/schedule_service.dart';
import '../services/auth_service.dart';

class UserScheduleBinding implements Bindings {
  @override
  void dependencies() {
    print("\nInitialisation du UserScheduleBinding");

    // Récupérer les services
    final authService = Get.find<AuthService>();

    // Créer le service avec le token actuel
    final scheduleService = ScheduleService(authService.token);
    Get.put<ScheduleService>(scheduleService, permanent: true);

    // Créer et enregistrer le controller
    final controller = UserScheduleController(scheduleService, authService);
    Get.put<UserScheduleController>(controller, permanent: true);

    // Imprimer les informations de débogage
    print("État initial:");
    print("Token présent: ${authService.token.isNotEmpty}");

    final user = authService.currentUser;
    if (user != null) {
      print("Utilisateur:");
      print("  ID: ${user.id}");
      print("  Role: ${user.role}");
      print("  Classe: ${user.className}");
      print("  Track: ${user.track}");
    } else {
      print("Aucun utilisateur connecté");
    }

    // Si le token est absent, le controller tentera de le récupérer lors du chargement
    if (authService.token.isEmpty) {
      print("Token absent - sera récupéré lors du chargement des données");
    }

    // Déclencher le chargement initial après la fin du cycle actuel
    Future.microtask(() {
      if (Get.isRegistered<UserScheduleController>()) {
        final controller = Get.find<UserScheduleController>();
        print("Déclenchement du chargement initial des données");
        controller.loadSchedule();
      }
    });
  }
}
