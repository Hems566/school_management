import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/Widgets/PageWrapper.dart';
import 'package:school_management/controllers/teacher_controller.dart';
import 'package:school_management/controllers/auth_controller.dart';
import 'package:school_management/utils/app_notification.dart';

class TeachersManagementPage extends StatefulWidget {
  const TeachersManagementPage({super.key});

  @override
  State<TeachersManagementPage> createState() => _TeachersManagementPageState();
}

class _TeachersManagementPageState extends State<TeachersManagementPage> {
  final TeacherController _teacherController = Get.find<TeacherController>();
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _teacherController.clearSelectedSubjects();
    super.dispose();
  }

  void _showTeacherDialog([Map<String, dynamic>? teacher]) {
    if (teacher != null) {
      _firstNameController.text = teacher['first_name'];
      _lastNameController.text = teacher['last_name'];
      _phoneController.text = teacher['phone_number'] ?? '';

      // Définir les matières sélectionnées
      if (teacher['subjects'] != null) {
        final subjectIds = (teacher['subjects'] as List)
            .map((subject) => subject['id'] as int)
            .toList();
        _teacherController.setSelectedSubjects(subjectIds);
      } else {
        _teacherController.clearSelectedSubjects();
      }
    } else {
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _teacherController.clearSelectedSubjects();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(teacher == null
            ? 'Ajouter un enseignant'
            : 'Modifier un enseignant'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Champ requis' : null,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Champ requis' : null,
                ),
                if (teacher == null)
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        (value?.isEmpty ?? true) || !GetUtils.isEmail(value!)
                            ? 'Email invalide'
                            : null,
                  ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Matières enseignées',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  if (_teacherController.availableSubjects.isEmpty) {
                    return const Text('Aucune matière disponible');
                  }
                  return Column(
                    children:
                        _teacherController.availableSubjects.map((subject) {
                      return Obx(() => CheckboxListTile(
                            title: Text(subject['name']),
                            subtitle: Text(subject['track']),
                            value: _teacherController.selectedSubjectIds
                                .contains(subject['id']),
                            onChanged: (bool? value) {
                              if (value == true) {
                                _teacherController.selectSubject(subject['id']);
                              } else {
                                _teacherController
                                    .unselectSubject(subject['id']);
                              }
                            },
                          ));
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _teacherController.clearSelectedSubjects();
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  if (teacher == null) {
                    // Créer un nouvel enseignant
                    final name =
                        '${_firstNameController.text} ${_lastNameController.text}';
                    final success = await _authController.requestLogin(
                      email: _emailController.text,
                      name: name,
                      rollNumber: 'T${DateTime.now().millisecondsSinceEpoch}',
                      className: 'Enseignant',
                      phoneNumber: _phoneController.text,
                      role: 'teacher',
                    );

                    if (success) {
                      AppNotification.showSuccess(
                          'Compte enseignant créé avec succès.\nEn attente d\'activation.');
                      if (mounted) Navigator.pop(context);
                    }
                  } else {
                    // Mettre à jour l'enseignant existant
                    await _teacherController.updateTeacher(
                      id: teacher['id'],
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      phoneNumber: _phoneController.text,
                      subjectIds: _teacherController.selectedSubjectIds,
                    );
                    AppNotification.showSuccess(
                        'Enseignant mis à jour avec succès');
                    await _teacherController.loadTeachers();
                    if (mounted) Navigator.pop(context);
                  }
                } catch (e) {
                  AppNotification.showError('Erreur: ${e.toString()}');
                }
              }
            },
            child: Text(teacher == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer l\'enseignant ${teacher['first_name']} ${teacher['last_name']} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _teacherController.deleteTeacher(teacher['id']);
                if (mounted) {
                  Navigator.pop(context);
                  AppNotification.showSuccess(
                      'Enseignant supprimé avec succès');
                }
              } catch (e) {
                AppNotification.showError(
                    'Erreur lors de la suppression: ${e.toString()}');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Gestion des Enseignants',
      showDrawer: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showTeacherDialog(),
        ),
      ],
      child: Obx(() {
        if (_teacherController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_teacherController.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _teacherController.error.value,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _teacherController.loadTeachers,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        final teachers = _teacherController.teachers;
        if (teachers.isEmpty) {
          return const Center(child: Text('Aucun enseignant enregistré'));
        }

        return ListView.builder(
          itemCount: teachers.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(
                  '${teacher['first_name']} ${teacher['last_name']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (teacher['phone_number'] != null &&
                        teacher['phone_number'].isNotEmpty)
                      Text('Téléphone: ${teacher['phone_number']}'),
                    if (teacher['subjects'] != null &&
                        (teacher['subjects'] as List).isNotEmpty)
                      Text(
                        'Matières: ${(teacher['subjects'] as List).map((s) => s['name']).join(", ")}',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showTeacherDialog(teacher),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(teacher),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
