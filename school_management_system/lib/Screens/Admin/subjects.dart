import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/controllers/subject_controller.dart';
import 'package:school_management/controllers/auth_controller.dart';
import 'package:school_management/models/subject_model.dart';
import 'package:school_management/services/UserModel.dart';
import 'package:school_management/Widgets/PageWrapper.dart';

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final SubjectController _subjectController = Get.find<SubjectController>();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _showAddEditDialog(BuildContext context,
      [Subject? subject]) async {
    _nameController.text = subject?.name ?? '';
    String selectedTrack = subject?.track ?? 'Réseaux et Systèmes Communicants';
    final selectedTeachers = <int>[].obs;

    if (subject != null && subject.teachers != null) {
      selectedTeachers.assignAll(subject.teachers!.map((t) => t.id));
    }

    await _subjectController.loadAvailableTeachers();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              subject == null ? 'Ajouter une matière' : 'Modifier la matière'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la matière',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Track',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedTrack,
                  items: [
                    'Réseaux et Systèmes Communicants',
                    'Systèmes Informations',
                  ].map((String track) {
                    return DropdownMenuItem<String>(
                      value: track,
                      child: Text(track),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      selectedTrack = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Sélectionner les enseignants :'),
                const SizedBox(height: 8),
                Obx(() {
                  if (_subjectController.availableTeachers.isEmpty) {
                    return const Text('Aucun enseignant disponible');
                  }
                  return Column(
                    children:
                        _subjectController.availableTeachers.map((teacher) {
                      return Obx(() => CheckboxListTile(
                            title: Text(teacher['full_name'] ?? 'Sans nom'),
                            value: selectedTeachers.contains(teacher['id']),
                            onChanged: (bool? value) {
                              if (value == true) {
                                selectedTeachers.add(teacher['id']);
                              } else {
                                selectedTeachers.remove(teacher['id']);
                              }
                            },
                          ));
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty &&
                    selectedTeachers.isNotEmpty) {
                  try {
                    if (subject == null) {
                      await _subjectController.createSubject(
                        name: _nameController.text,
                        track: selectedTrack,
                        teacherIds: selectedTeachers,
                      );
                    } else {
                      await _subjectController.updateSubject(
                        id: subject.id,
                        name: _nameController.text,
                        track: selectedTrack,
                        teacherIds: selectedTeachers,
                      );
                    }
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Veuillez remplir tous les champs et sélectionner au moins un enseignant'),
                    ),
                  );
                }
              },
              child: Text(subject == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Subject subject) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
              'Êtes-vous sûr de vouloir supprimer la matière "${subject.name}" ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await _subjectController.deleteSubject(subject.id);
                Navigator.pop(context);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Gestion des matières',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
      child: Obx(() {
        if (_subjectController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_subjectController.subjects.isEmpty) {
          return const Center(child: Text('Aucune matière n\'a été ajoutée'));
        }

        return ListView.builder(
          itemCount: _subjectController.subjects.length,
          itemBuilder: (context, index) {
            final subject = _subjectController.subjects[index];
            return Card(
              child: ListTile(
                title: Text(subject.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.track),
                    if (subject.teachers != null &&
                        subject.teachers!.isNotEmpty)
                      Text(
                        'Enseignants: ${subject.teachers!.map((t) => t.name).join(", ")}',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAddEditDialog(context, subject),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(context, subject),
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
