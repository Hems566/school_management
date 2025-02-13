import 'package:flutter/material.dart';
import '../services/schedule_service.dart';
import 'dart:ui' as ui;

class SchedulePainter extends StatefulWidget {
  final List<ScheduleEntry> schedules;
  final bool isAdmin;
  final Function(ScheduleEntry)? onEdit;
  final Function(int)? onDelete;

  static const List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  const SchedulePainter({
    Key? key,
    required this.schedules,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  State<SchedulePainter> createState() => _SchedulePainterState();
}

class _SchedulePainterState extends State<SchedulePainter> {
  Offset? mousePosition;
  double? hoveredCellLeft;
  double? hoveredCellTop;
  ScheduleEntry? hoveredEntry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculer les dimensions en fonction de la largeur disponible
        final availableWidth = constraints.maxWidth;
        final timeColumnWidth =
            availableWidth * 0.1; // 10% pour la colonne temps
        final dayColumnWidth =
            (availableWidth - timeColumnWidth) / 6; // Reste divisé par 6 jours
        final rowHeight =
            dayColumnWidth * 0.4; // Hauteur proportionnelle à la largeur
        final headerHeight = rowHeight * 0.5;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: MouseRegion(
              onHover: (event) {
                if (widget.isAdmin) {
                  setState(() {
                    mousePosition = event.localPosition;
                    // Calculer la cellule survolée
                    final x = event.localPosition.dx;
                    final y = event.localPosition.dy;

                    hoveredCellLeft = null;
                    hoveredCellTop = null;
                    hoveredEntry = null;

                    if (y > headerHeight) {
                      for (int i = 0; i < 6; i++) {
                        final cellLeft = timeColumnWidth + (i * dayColumnWidth);
                        if (x >= cellLeft && x < cellLeft + dayColumnWidth) {
                          final row = ((y - headerHeight) / rowHeight).floor();
                          final entries = widget.schedules.where((entry) {
                            return entry.dayOfWeek == SchedulePainter.days[i] &&
                                _getTimeSlotForY(y - headerHeight, rowHeight) ==
                                    entry.startTime;
                          }).toList();

                          if (entries.isNotEmpty) {
                            hoveredCellLeft = cellLeft;
                            hoveredCellTop = headerHeight + (row * rowHeight);
                            hoveredEntry = entries.first;
                          }
                          break;
                        }
                      }
                    }
                  });
                }
              },
              onExit: (_) {
                setState(() {
                  mousePosition = null;
                  hoveredCellLeft = null;
                  hoveredCellTop = null;
                  hoveredEntry = null;
                });
              },
              child: SizedBox(
                width: timeColumnWidth + (6 * dayColumnWidth),
                height: headerHeight + (10 * rowHeight),
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: _ScheduleGridPainter(
                        schedules: widget.schedules,
                        context: context,
                        timeColumnWidth: timeColumnWidth,
                        dayColumnWidth: dayColumnWidth,
                        rowHeight: rowHeight,
                        headerHeight: headerHeight,
                      ),
                      size: Size(timeColumnWidth + (6 * dayColumnWidth),
                          headerHeight + (10 * rowHeight)),
                    ),
                    if (widget.isAdmin && hoveredEntry != null)
                      Positioned(
                        left: hoveredCellLeft! + dayColumnWidth - 40,
                        top: hoveredCellTop! + 5,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            if (widget.onDelete != null) {
                              widget.onDelete!(hoveredEntry!.id);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getTimeSlotForY(double y, double rowHeight) {
    final timeSlots = [
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00'
    ];
    final index = (y / rowHeight).floor();
    if (index >= 0 && index < timeSlots.length) {
      return timeSlots[index];
    }
    return timeSlots[0];
  }
}

class _ScheduleGridPainter extends CustomPainter {
  final List<ScheduleEntry> schedules;
  final BuildContext context;
  final double timeColumnWidth;
  final double dayColumnWidth;
  final double rowHeight;
  final double headerHeight;

  static const List<String> timeSlots = [
    '08:00-09:00',
    '09:00-10:00',
    '10:00-11:00',
    '11:00-12:00',
    '12:00-13:00',
    '13:00-14:00',
    '14:00-15:00',
    '15:00-16:00',
    '16:00-17:00',
    '17:00-18:00'
  ];

  _ScheduleGridPainter({
    required this.schedules,
    required this.context,
    required this.timeColumnWidth,
    required this.dayColumnWidth,
    required this.rowHeight,
    required this.headerHeight,
  });

  Color _getSubjectColor(int subjectId) {
    // Générer une couleur unique basée sur l'ID de la matière
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[subjectId % colors.length];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final headerPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.fill;

    final margin = 2.0; // Marge entre les cellules
    final cornerRadius = 4.0; // Rayon des coins arrondis

    // Dessiner l'en-tête avec les jours
    _drawRoundedRect(
        canvas,
        Rect.fromLTWH(0, 0, timeColumnWidth - margin, headerHeight - margin),
        cornerRadius,
        headerPaint);
    _drawText(
        canvas, 'Time', Offset(timeColumnWidth / 2, headerHeight / 2), true);

    for (int i = 0; i < SchedulePainter.days.length; i++) {
      final left = timeColumnWidth + i * dayColumnWidth;
      _drawRoundedRect(
          canvas,
          Rect.fromLTWH(left + margin, 0, dayColumnWidth - margin * 2,
              headerHeight - margin),
          cornerRadius,
          headerPaint);
      _drawText(canvas, SchedulePainter.days[i],
          Offset(left + dayColumnWidth / 2, headerHeight / 2), true);
    }

    // Dessiner la grille des créneaux horaires
    for (int i = 0; i < timeSlots.length; i++) {
      final top = headerHeight + i * rowHeight;

      // Colonne des heures
      _drawRoundedRect(
          canvas,
          Rect.fromLTWH(
              0, top + margin, timeColumnWidth - margin, rowHeight - margin),
          cornerRadius,
          headerPaint);
      _drawText(canvas, timeSlots[i],
          Offset(timeColumnWidth / 2, top + rowHeight / 2), false);

      // Cellules pour chaque jour
      for (int j = 0; j < SchedulePainter.days.length; j++) {
        final left = timeColumnWidth + j * dayColumnWidth;
        _drawRoundedRect(
          canvas,
          Rect.fromLTWH(left + margin, top + margin,
              dayColumnWidth - margin * 2, rowHeight - margin),
          cornerRadius,
          paint,
        );

        // Dessiner les cours
        final entriesInSlot =
            _getEntriesForSlot(SchedulePainter.days[j], timeSlots[i]);
        if (entriesInSlot.isNotEmpty) {
          final entry = entriesInSlot.first;
          final duration = _calculateDuration(entry);
          final height = (duration * rowHeight).toDouble();

          final subjectColor = _getSubjectColor(entry.subjectId);
          final coursePaint = Paint()
            ..color = subjectColor.withOpacity(0.15)
            ..style = PaintingStyle.fill;

          final borderPaint = Paint()
            ..color = subjectColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;

          final courseRect = Rect.fromLTWH(left + margin, top + margin,
              dayColumnWidth - margin * 2, height - margin);

          // Dessiner le fond avec coins arrondis
          _drawRoundedRect(canvas, courseRect, cornerRadius, coursePaint);
          // Dessiner la bordure avec coins arrondis
          _drawRoundedRect(canvas, courseRect, cornerRadius, borderPaint);

          // Texte du cours avec style amélioré
          final courseText =
              '${entry.subjectName ?? ""}\n${entry.teacherName ?? ""}\n${entry.roomNumber}';
          _drawMultilineText(
            canvas,
            courseText,
            Rect.fromLTWH(left + margin + 8, top + margin + 8,
                dayColumnWidth - margin * 2 - 16, height - margin * 2 - 16),
            subjectColor.darken(),
          );
        }
      }
    }
  }

  void _drawRoundedRect(Canvas canvas, Rect rect, double radius, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }

  void _drawText(Canvas canvas, String text, Offset center, bool isBold) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: isBold ? dayColumnWidth * 0.06 : dayColumnWidth * 0.05,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: dayColumnWidth * 0.9);
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawMultilineText(
      Canvas canvas, String text, Rect bounds, Color textColor) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: dayColumnWidth * 0.05,
          height: 1.2,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 3,
      ellipsis: '...',
    );
    textPainter.layout(
      minWidth: bounds.width,
      maxWidth: bounds.width,
    );
    textPainter.paint(
      canvas,
      Offset(
        bounds.left + (bounds.width - textPainter.width) / 2,
        bounds.top + (bounds.height - textPainter.height) / 2,
      ),
    );
  }

  List<ScheduleEntry> _getEntriesForSlot(String day, String timeSlot) {
    final slotStartHour = int.parse(timeSlot.split('-')[0].split(':')[0]);
    final slotStartMinute = int.parse(timeSlot.split('-')[0].split(':')[1]);
    final slotStart = slotStartHour * 60 + slotStartMinute;

    return schedules.where((schedule) {
      final scheduleStartHour = int.parse(schedule.startTime.split(':')[0]);
      final scheduleStartMinute = int.parse(schedule.startTime.split(':')[1]);
      final scheduleStart = scheduleStartHour * 60 + scheduleStartMinute;

      return schedule.dayOfWeek == day && scheduleStart == slotStart;
    }).toList();
  }

  int _calculateDuration(ScheduleEntry entry) {
    final startHour = int.parse(entry.startTime.split(':')[0]);
    final startMinute = int.parse(entry.startTime.split(':')[1]);
    final endHour = int.parse(entry.endTime.split(':')[0]);
    final endMinute = int.parse(entry.endTime.split(':')[1]);

    final startInMinutes = startHour * 60 + startMinute;
    final endInMinutes = endHour * 60 + endMinute;
    final durationInMinutes = endInMinutes - startInMinutes;

    return (durationInMinutes / 60).ceil();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
