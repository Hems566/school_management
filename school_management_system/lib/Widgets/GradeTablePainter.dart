import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/UserModel.dart';
import '../controllers/exam_controller.dart';

class GradeTablePainter extends StatefulWidget {
  final List<UserModel> students;
  final List<Map<String, dynamic>> results;
  final Function(int studentId, String field, String value) onGradeUpdated;

  const GradeTablePainter({
    Key? key,
    required this.students,
    required this.results,
    required this.onGradeUpdated,
  }) : super(key: key);

  @override
  State<GradeTablePainter> createState() => _GradeTablePainterState();
}

class _GradeTablePainterState extends State<GradeTablePainter> {
  // Map to store temporary grades before validation
  final Map<String, Map<String, TextEditingController>> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  static const columns = [
    {'field': 'student', 'label': 'Étudiant', 'width': 0.3},
    {'field': 'tp_score', 'label': 'TP (20%)', 'width': 0.14},
    {
      'field': 'continuous_assessment_score',
      'label': 'CC (30%)',
      'width': 0.14
    },
    {'field': 'final_exam_score', 'label': 'Examen (50%)', 'width': 0.14},
    {'field': 'retake_score', 'label': 'Rattrapage', 'width': 0.14},
    {'field': 'final_score', 'label': 'Note Finale', 'width': 0.14},
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(GradeTablePainter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.results != widget.results) {
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    // Clean up controllers and focus nodes
    for (var studentControllers in _controllers.values) {
      for (var controller in studentControllers.values) {
        controller.dispose();
      }
    }
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    // Clear existing controllers
    _controllers.clear();
    _focusNodes.clear();

    for (var student in widget.students) {
      final studentId = student.id.toString();
      final result = widget.results.firstWhereOrNull(
        (r) => r['student_id'] == student.id,
      );

      // Initialize focus nodes for each field
      columns.skip(1).take(4).forEach((column) {
        final fieldKey = '${studentId}_${column['field']}';
        _focusNodes[fieldKey] = FocusNode();
      });

      // Initialize controllers with current values
      _controllers[studentId] = {
        'tp_score':
            TextEditingController(text: result?['tp_score']?.toString() ?? ''),
        'continuous_assessment_score': TextEditingController(
            text: result?['continuous_assessment_score']?.toString() ?? ''),
        'final_exam_score': TextEditingController(
            text: result?['final_exam_score']?.toString() ?? ''),
        'retake_score': TextEditingController(
            text: result?['retake_score']?.toString() ?? ''),
      };
    }
  }

  void _submitAllGrades(int studentId) {
    final studentControllers = _controllers[studentId.toString()];
    if (studentControllers == null) return;

    // Submit each non-empty grade
    studentControllers.forEach((field, controller) {
      final value = controller.text.trim();
      if (value.isNotEmpty) {
        widget.onGradeUpdated(studentId, field, value);
      }
    });
  }

  Widget _buildGradeTextField(
      int studentId, String field, dynamic initialValue) {
    final controller = _controllers[studentId.toString()]?[field];
    final focusNode = _focusNodes['${studentId}_$field'];
    if (controller == null || focusNode == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            _submitAllGrades(studentId);
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
          ),
          style: const TextStyle(fontSize: 16),
          onSubmitted: (_) => _submitAllGrades(studentId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final rowHeight = 50.0;
        final headerHeight = 60.0;

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            width: availableWidth,
            height: headerHeight + (widget.students.length * rowHeight),
            child: CustomPaint(
              painter: _GradeGridPainter(
                students: widget.students,
                results: widget.results,
                context: context,
                headerHeight: headerHeight,
                rowHeight: rowHeight,
                totalWidth: availableWidth,
              ),
              child: _buildEditableFields(
                availableWidth,
                headerHeight,
                rowHeight,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditableFields(
      double totalWidth, double headerHeight, double rowHeight) {
    return Stack(
      children: [
        for (int i = 0; i < widget.students.length; i++)
          for (var column
              in columns.skip(1).take(4)) // Skip student name and final score
            Positioned(
              left: _getColumnStart(totalWidth, column['field'] as String),
              top: headerHeight + (i * rowHeight),
              width: _getColumnWidth(totalWidth, column['field'] as String),
              height: rowHeight,
              child: _buildGradeTextField(
                widget.students[i].id,
                column['field'] as String,
                widget.results.firstWhereOrNull(
                  (r) => r['student_id'] == widget.students[i].id,
                )?[column['field']],
              ),
            ),
      ],
    );
  }

  double _getColumnStart(double totalWidth, String field) {
    double start = 0;
    for (var column in columns) {
      if (column['field'] == field) break;
      start += totalWidth * (column['width'] as double);
    }
    return start;
  }

  double _getColumnWidth(double totalWidth, String field) {
    return totalWidth *
        (columns.firstWhere((c) => c['field'] == field)['width'] as double);
  }
}

class _GradeGridPainter extends CustomPainter {
  final List<UserModel> students;
  final List<Map<String, dynamic>> results;
  final BuildContext context;
  final double headerHeight;
  final double rowHeight;
  final double totalWidth;

  _GradeGridPainter({
    required this.students,
    required this.results,
    required this.context,
    required this.headerHeight,
    required this.rowHeight,
    required this.totalWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final headerPaint = Paint()
      ..color = Colors.green.shade50
      ..style = PaintingStyle.fill;

    final margin = 1.0;
    final cornerRadius = 4.0;

    // Draw headers
    double currentX = 0;
    for (var column in _GradeTablePainterState.columns) {
      final width = totalWidth * (column['width'] as double);
      _drawHeader(
        canvas,
        Rect.fromLTWH(
          currentX + margin,
          margin,
          width - margin * 2,
          headerHeight - margin * 2,
        ),
        column['label'] as String,
        cornerRadius,
        headerPaint,
      );
      currentX += width;
    }

    // Draw rows
    for (int i = 0; i < students.length; i++) {
      final student = students[i];
      final result =
          results.firstWhereOrNull((r) => r['student_id'] == student.id);
      final top = headerHeight + (i * rowHeight);

      // Set background color based on final score
      final finalScore =
          double.tryParse(result?['final_score']?.toString() ?? '0') ?? 0;
      final rowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = finalScore < 10
            ? Colors.red.shade50
            : finalScore < 12
                ? Colors.orange.shade50
                : Colors.green.shade50;

      currentX = 0;
      for (var column in _GradeTablePainterState.columns) {
        final width = totalWidth * (column['width'] as double);
        final rect = Rect.fromLTWH(
          currentX + margin,
          top + margin,
          width - margin * 2,
          rowHeight - margin * 2,
        );

        // Draw cell background
        _drawRoundedRect(canvas, rect, cornerRadius, rowPaint);
        // Draw cell border
        _drawRoundedRect(canvas, rect, cornerRadius, paint);

        // Draw text for student name and final score
        if (column['field'] == 'student') {
          _drawText(
            canvas,
            '${student.firstName} ${student.lastName}',
            rect,
            Colors.black87,
          );
        } else if (column['field'] == 'final_score') {
          _drawText(
            canvas,
            result?['final_score']?.toString() ?? '-',
            rect,
            _getScoreColor(finalScore),
            true,
          );
        }

        currentX += width;
      }
    }
  }

  void _drawHeader(
    Canvas canvas,
    Rect rect,
    String text,
    double radius,
    Paint backgroundPaint,
  ) {
    _drawRoundedRect(canvas, rect, radius, backgroundPaint);

    final borderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    _drawRoundedRect(canvas, rect, radius, borderPaint);

    _drawText(canvas, text, rect, Colors.black87, true);
  }

  void _drawRoundedRect(Canvas canvas, Rect rect, double radius, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Rect rect,
    Color color, [
    bool isBold = false,
  ]) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(minWidth: 0, maxWidth: rect.width);
    textPainter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - textPainter.width) / 2,
        rect.top + (rect.height - textPainter.height) / 2,
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score < 10) return Colors.red.shade900;
    if (score < 12) return Colors.orange.shade900;
    return Colors.green.shade900;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
