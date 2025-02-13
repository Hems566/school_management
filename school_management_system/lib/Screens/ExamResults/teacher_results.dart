import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/controllers/auth_controller.dart';
import 'package:school_management/controllers/exam_controller.dart';
import 'package:school_management/Widgets/PageWrapper.dart';
import 'package:school_management/Widgets/GradeInputForm.dart';
import 'package:school_management/services/UserModel.dart';

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
              _buildTrackSelection(),
              const SizedBox(height: 24),
              _buildStudentsList(),
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
                  onChanged: _examController.selectTrack,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return Obx(() {
      if (_examController.selectedTrack.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Étudiants - ${_examController.selectedTrack.value}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_examController.isLoadingStudents.value)
                const Center(child: CircularProgressIndicator())
              else if (_examController.students.isEmpty)
                const Text('Aucun étudiant trouvé pour ce track')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _examController.students.length,
                  itemBuilder: (context, index) {
                    final student = _examController.students[index];
                    return ListTile(
                      title: Text(
                          '${student.firstName} ${student.lastName}'.trim()),
                      subtitle: Text('#${student.id}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _examController.selectedStudentId.value = student.id;
                          _showGradeInputDialog(context, student);
                        },
                        child: const Text('Saisir les notes'),
                      ),
                    );
                  },
                ),
              if (_examController.results.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Résultats',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildResultsTable(),
              ],
            ],
          ),
        ),
      );
    });
  }

  void _showGradeInputDialog(BuildContext context, UserModel student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Saisie des notes pour ${student.firstName} ${student.lastName}'
                      .trim(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GradeInputForm(
                  onSave: (data) {
                    _examController.addOrUpdateGrade(
                      student.id,
                      data['subject_id'] as int,
                      data,
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsTable() {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Étudiant')),
            DataColumn(label: Text('TP (20%)')),
            DataColumn(label: Text('CC (30%)')),
            DataColumn(label: Text('Examen (50%)')),
            DataColumn(label: Text('Rattrapage')),
            DataColumn(label: Text('Note Finale')),
          ],
          rows: _examController.results.map((result) {
            return DataRow(
              cells: [
                DataCell(Text(result['student_name'] ?? '')),
                DataCell(Text(result['tp_score']?.toString() ?? '-')),
                DataCell(Text(
                    result['continuous_assessment_score']?.toString() ?? '-')),
                DataCell(Text(result['final_exam_score']?.toString() ?? '-')),
                DataCell(Text(result['retake_score']?.toString() ?? '-')),
                DataCell(Text(result['final_score']?.toString() ?? '-')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
