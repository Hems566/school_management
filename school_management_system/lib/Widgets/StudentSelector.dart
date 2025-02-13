import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/services/UserModel.dart';

class StudentSelector extends StatelessWidget {
  final Function(int) onStudentSelected;
  final List<UserModel> students;
  final int? selectedStudentId;
  final bool isLoading;

  const StudentSelector({
    super.key,
    required this.onStudentSelected,
    required this.students,
    this.selectedStudentId,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<int>(
      value: selectedStudentId,
      decoration: const InputDecoration(
        labelText: 'Étudiant',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      items: students.map((student) {
        return DropdownMenuItem<int>(
          value: student.id,
          child: Text('${student.name} (${student.rollNumber})'),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onStudentSelected(value);
        }
      },
      validator: (value) =>
          value == null ? 'Veuillez sélectionner un étudiant' : null,
    );
  }
}
