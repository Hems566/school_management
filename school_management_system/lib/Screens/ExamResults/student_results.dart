import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/controllers/auth_controller.dart';
import 'package:school_management/controllers/exam_controller.dart';
import 'package:school_management/Widgets/PageWrapper.dart';

class StudentResultsPage extends GetView<ExamController> {
  final AuthController _authController = Get.find<AuthController>();

  StudentResultsPage({super.key}) {
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      final userId = _authController.currentUser.value?.id;
      if (userId != null) {
        // D'abord récupérer l'ID étudiant
        print('Getting student ID for user: $userId');
        final studentId = await controller.examService.getStudentId(userId);
        print('Got student ID: $studentId');

        // Ensuite charger les résultats avec l'ID étudiant
        await controller.loadStudentResults(studentId);
        await controller.calculateGeneralAverage(studentId);
      }
    } catch (e) {
      print('Error loading results: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger les résultats: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Mes résultats',
      showDrawer: true,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultsTable(),
              const SizedBox(height: 24),
              if (controller.finalResult.value != null) _buildFinalResults(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildResultsTable() {
    if (controller.results.isEmpty) {
      return const Center(child: Text('Aucun résultat disponible'));
    }

    return Card(
      child: SingleChildScrollView(
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
          rows: controller.results.map((result) {
            return DataRow(
              cells: [
                DataCell(Text(result['subject_name'] ?? '')),
                DataCell(Text(result['tp_score']?.toString() ?? '-')),
                DataCell(Text(
                    result['continuous_assessment_score']?.toString() ?? '-')),
                DataCell(Text(result['final_exam_score']?.toString() ?? '-')),
                DataCell(Text(result['retake_score']?.toString() ?? '-')),
                DataCell(Text(result['final_score']?.toString() ?? '-')),
                DataCell(Text(result['coefficient']?.toString() ?? '1')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFinalResults() {
    final finalResult = controller.finalResult.value!;
    final generalAverage = finalResult['generalAverage'] as double;
    final isValidated = controller.isValidated(generalAverage);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Moyenne Générale: ${generalAverage.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Décision: ${isValidated ? 'Validé' : 'Non validé'}',
              style: TextStyle(
                fontSize: 16,
                color: isValidated ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
