import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/controllers/auth_controller.dart';
import 'package:school_management/controllers/exam_controller.dart';
import 'package:school_management/controllers/subject_controller.dart';
import 'package:school_management/Widgets/PageWrapper.dart';
import 'package:school_management/Widgets/GradeInputForm.dart';
import 'package:school_management/services/UserModel.dart';
import 'package:school_management/utils/app_notification.dart';
import 'package:school_management/Widgets/GradeTablePainter.dart';

class TeacherResultsPage extends StatelessWidget {
  final ExamController _examController = Get.find<ExamController>();
  final AuthController _authController = Get.find<AuthController>();

  TeacherResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Résultats des élèves',
      showDrawer: true,
      child: Obx(() {
        if (_examController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildTrackSelection(),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: _buildSubjectSelection(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Obx(() => _examController.selectedSubject.value.isNotEmpty
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.book,
                                  color: Colors.green, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Matière sélectionnée',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _examController.selectedSubject.value,
                                      style: const TextStyle(
                                        fontSize: 20,
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
                    )
                  : const SizedBox.shrink()),
              _buildCombinedTable(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTrackSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sélection du Track',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Track',
                    border: OutlineInputBorder(),
                  ),
                  value: _examController.selectedTrack.value,
                  items: _examController.tracks
                      .map((String track) => DropdownMenuItem(
                            value: track,
                            child: Text(track),
                          ))
                      .toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un track';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _examController.selectTrack(value);
                    _examController.loadAllResults();
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectSelection() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sélection de la Matière',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GetBuilder<SubjectController>(
              init: Get.find<SubjectController>(),
              builder: (subjectController) {
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Matière',
                    border: OutlineInputBorder(),
                  ),
                  value: _examController.selectedSubject.value.isEmpty
                      ? null
                      : _examController.selectedSubject.value,
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Toutes les matières'),
                    ),
                    ...subjectController.subjects
                        .map((subject) => DropdownMenuItem(
                              value: subject.name,
                              child: Text(subject.name),
                            ))
                        .toList(),
                  ],
                  onChanged: (value) {
                    _examController.selectSubject(value ?? '');
                    _examController.loadAllResults();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedTable() {
    return Obx(() {
      if (_examController.selectedTrack.value.isEmpty) {
        return const Center(
          child: Text('Veuillez sélectionner un track et une matière'),
        );
      }

      if (_examController.isLoadingStudents.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_examController.students.isEmpty) {
        return const Center(
          child: Text('Aucun étudiant trouvé pour ce track'),
        );
      }

      return Card(
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GradeTablePainter(
            students: _examController.students,
            results: _examController.results,
            onGradeUpdated: (studentId, field, value) {
              if (value.isEmpty) return;

              final score = double.tryParse(value);
              if (score == null || score < 0 || score > 20) {
                AppNotification.showError(
                    'La note doit être comprise entre 0 et 20');
                return;
              }

              final subjectController = Get.find<SubjectController>();
              final selectedSubject = subjectController.subjects.firstWhere(
                (s) => s.name == _examController.selectedSubject.value,
                orElse: () => throw Exception('Matière non trouvée'),
              );

              final data = {
                'subject_id': selectedSubject.id,
                'tp_score': field == 'tp_score' ? score : null,
                'continuous_assessment_score':
                    field == 'continuous_assessment_score' ? score : null,
                'final_exam_score': field == 'final_exam_score' ? score : null,
                'retake_score': field == 'retake_score' ? score : null,
              };

              _examController.addOrUpdateGrade(
                  studentId, selectedSubject.id, data);
            },
          ),
        ),
      );
    });
  }
}
