import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/controllers/exam_controller.dart';
import 'package:school_management/controllers/auth_controller.dart';
import 'package:school_management/Widgets/PageWrapper.dart';
import 'package:school_management/Widgets/GradeInputForm.dart';
import 'package:school_management/Widgets/StudentSelector.dart';

class ExamResultsScreen extends StatelessWidget {
  final ExamController _examController = Get.find<ExamController>();
  final AuthController _authController = Get.find<AuthController>();

  ExamResultsScreen({super.key}) {
    // Charger les résultats au démarrage
    final userId = _authController.currentUser.value?.id;
    if (userId != null &&
        _authController.currentUser.value?.role == 'student') {
      _examController.loadStudentResults(userId);
      _examController.calculateGeneralAverage(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Résultats d\'examens',
      showDrawer: true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (_examController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_examController.isAdmin || _examController.isTeacher)
                _buildInputSection(),
              const SizedBox(height: 24),
              _buildResultsSection(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saisie des notes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_examController.isTeacher)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Sélectionnez un track',
                  border: OutlineInputBorder(),
                ),
                value: _examController.selectedTrack.value.isEmpty
                    ? null
                    : _examController.selectedTrack.value,
                items: _examController.tracks.map((String track) {
                  return DropdownMenuItem<String>(
                    value: track,
                    child: Text(track),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    _examController.selectTrack(value);
                  }
                },
              ),
            if (_examController.selectedTrack.value.isNotEmpty)
              const SizedBox(height: 16),
            if (_examController.selectedTrack.value.isNotEmpty)
              StudentSelector(
                students: _examController.students.toList(),
                selectedStudentId: _examController.selectedStudentId.value,
                onStudentSelected: (studentId) {
                  _examController.selectedStudentId.value = studentId;
                  _examController.loadStudentResults(studentId);
                  _examController.calculateGeneralAverage(studentId);
                },
                isLoading: _examController.isLoadingStudents.value,
              ),
            const SizedBox(height: 16),
            GradeInputForm(
              onSave: (Map<String, dynamic> data) {
                if (_examController.selectedStudentId.value != null) {
                  _examController.addOrUpdateGrade(
                    _examController.selectedStudentId.value!,
                    data['subject_id'] as int,
                    data,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_examController.results.isEmpty) {
      return const Center(
        child: Text('Aucun résultat disponible'),
      );
    }

    return Card(
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Matière')),
                DataColumn(label: Text('TP (20%)')),
                DataColumn(label: Text('CC (30%)')),
                DataColumn(label: Text('Examen (50%)')),
                DataColumn(label: Text('Rattrapage')),
                DataColumn(label: Text('Note Finale')),
                DataColumn(label: Text('Coefficient')),
              ],
              rows: _examController.results.map((result) {
                return DataRow(
                  cells: [
                    DataCell(Text(result['subject_name'] ?? '')),
                    DataCell(Text(result['tp_score']?.toString() ?? '-')),
                    DataCell(Text(
                        result['continuous_assessment_score']?.toString() ??
                            '-')),
                    DataCell(
                        Text(result['final_exam_score']?.toString() ?? '-')),
                    DataCell(Text(result['retake_score']?.toString() ?? '-')),
                    DataCell(Text(result['final_score']?.toString() ?? '-')),
                    DataCell(Text(result['coefficient']?.toString() ?? '1')),
                  ],
                );
              }).toList(),
            ),
          ),
          if (_examController.finalResult.value != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Moyenne Générale: ${_examController.finalResult.value!['generalAverage']?.toStringAsFixed(2) ?? '-'}/20',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Décision: ${_examController.finalResult.value!['decision'] ?? '-'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _examController.finalResult.value!['decision'] ==
                              'validé'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
