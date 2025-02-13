import 'package:flutter/material.dart';
import '../services/schedule_service.dart';

class ScheduleCell extends StatefulWidget {
  final ScheduleEntry entry;
  final bool isAdmin;
  final Function(ScheduleEntry)? onEdit;
  final Function(int)? onDelete;

  const ScheduleCell({
    Key? key,
    required this.entry,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  State<ScheduleCell> createState() => _ScheduleCellState();
}

class _ScheduleCellState extends State<ScheduleCell> {
  bool _isHovered = false;

  int calculateDurationInHours() {
    final startHour = int.parse(widget.entry.startTime.split(':')[0]);
    final startMinute = int.parse(widget.entry.startTime.split(':')[1]);
    final endHour = int.parse(widget.entry.endTime.split(':')[0]);
    final endMinute = int.parse(widget.entry.endTime.split(':')[1]);

    final totalStartMinutes = startHour * 60 + startMinute;
    final totalEndMinutes = endHour * 60 + endMinute;
    final durationInMinutes = totalEndMinutes - totalStartMinutes;

    return (durationInMinutes / 60).ceil();
  }

  Color getCellColor() {
    final duration = calculateDurationInHours();
    if (duration > 1) {
      return Colors.indigo.shade50; // Couleur différente pour les cours longs
    }
    return Colors.blue.shade50;
  }

  @override
  Widget build(BuildContext context) {
    final durationInHours = calculateDurationInHours();
    final cellHeight = 120.0 * durationInHours;

    return SizedBox(
      height: cellHeight,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Card(
          margin: const EdgeInsets.all(4),
          color: getCellColor(),
          elevation: _isHovered ? 4 : 1,
          child: InkWell(
            onTap: widget.isAdmin && widget.onEdit != null
                ? () => widget.onEdit!(widget.entry)
                : null,
            child: Stack(
              children: [
                Tooltip(
                  message: '''
Matière: ${widget.entry.subjectName ?? 'N/A'}
Enseignant: ${widget.entry.teacherName ?? 'N/A'}
Salle: ${widget.entry.roomNumber}
Classe: ${widget.entry.className}
Horaire: ${widget.entry.startTime} - ${widget.entry.endTime}
Durée: $durationInHours heure${durationInHours > 1 ? 's' : ''}
''',
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.entry.subjectName ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.entry.teacherName ?? 'N/A',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Salle: ${widget.entry.roomNumber}',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.entry.className.isNotEmpty)
                          Text(
                            'Classe: ${widget.entry.className}',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.entry.startTime} - ${widget.entry.endTime}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.isAdmin && widget.onDelete != null && _isHovered)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon:
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => widget.onDelete!(widget.entry.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
