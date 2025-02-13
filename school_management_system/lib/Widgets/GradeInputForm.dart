import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:school_management/controllers/subject_controller.dart';
import 'package:school_management/models/subject_model.dart';

class GradeInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialValues;

  const GradeInputForm({
    super.key,
    required this.onSave,
    this.initialValues,
  });

  @override
  State<GradeInputForm> createState() => _GradeInputFormState();
}

class _GradeInputFormState extends State<GradeInputForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tpController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _examScoreController = TextEditingController();
  final TextEditingController _retakeController = TextEditingController();
  final SubjectController _subjectController = Get.find<SubjectController>();

  int? selectedSubjectId;
  double finalScore = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialValues != null) {
      _tpController.text = widget.initialValues!['tp_score']?.toString() ?? '';
      _ccController.text =
          widget.initialValues!['continuous_assessment_score']?.toString() ??
              '';
      _examScoreController.text =
          widget.initialValues!['final_exam_score']?.toString() ?? '';
      _retakeController.text =
          widget.initialValues!['retake_score']?.toString() ?? '';
      selectedSubjectId = widget.initialValues!['subject_id'];
    }
    _loadSubjects();
    _setupListeners();
  }

  void _loadSubjects() {
    _subjectController.loadSubjects();
  }

  void _setupListeners() {
    void calculateFinalScore() {
      double tp = double.tryParse(_tpController.text) ?? 0;
      double cc = double.tryParse(_ccController.text) ?? 0;
      double exam = double.tryParse(_examScoreController.text) ?? 0;
      double retake = double.tryParse(_retakeController.text) ?? 0;

      if (retake > 0) {
        finalScore = (exam + retake) / 2;
      } else {
        finalScore = (tp * 0.2) + (cc * 0.3) + (exam * 0.5);
      }
      setState(() {});
    }

    _tpController.addListener(calculateFinalScore);
    _ccController.addListener(calculateFinalScore);
    _examScoreController.addListener(calculateFinalScore);
    _retakeController.addListener(calculateFinalScore);
  }

  @override
  void dispose() {
    _tpController.dispose();
    _ccController.dispose();
    _examScoreController.dispose();
    _retakeController.dispose();
    super.dispose();
  }

  String? _validateGrade(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Veuillez entrer un nombre valide';
    }
    if (number < 0 || number > 20) {
      return 'La note doit être entre 0 et 20';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => DropdownButtonFormField<int>(
                value: selectedSubjectId,
                decoration: const InputDecoration(
                  labelText: 'Matière',
                  border: OutlineInputBorder(),
                ),
                items: _subjectController.subjects.map((Subject subject) {
                  return DropdownMenuItem<int>(
                    value: subject.id,
                    child: Text(subject.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubjectId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner une matière' : null,
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _tpController,
                  decoration: const InputDecoration(
                    labelText: 'TP (20%)',
                    border: OutlineInputBorder(),
                    suffixText: '/20',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: _validateGrade,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _ccController,
                  decoration: const InputDecoration(
                    labelText: 'CC (30%)',
                    border: OutlineInputBorder(),
                    suffixText: '/20',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: _validateGrade,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _examScoreController,
                  decoration: const InputDecoration(
                    labelText: 'Examen (50%)',
                    border: OutlineInputBorder(),
                    suffixText: '/20',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: _validateGrade,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _retakeController,
                  decoration: const InputDecoration(
                    labelText: 'Rattrapage',
                    border: OutlineInputBorder(),
                    suffixText: '/20',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: _validateGrade,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  'Note finale: ${finalScore.toStringAsFixed(2)}/20',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSave({
                        'subject_id': selectedSubjectId,
                        'tp_score': double.tryParse(_tpController.text),
                        'continuous_assessment_score':
                            double.tryParse(_ccController.text),
                        'final_exam_score':
                            double.tryParse(_examScoreController.text),
                        'retake_score': double.tryParse(_retakeController.text),
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Enregistrer',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
