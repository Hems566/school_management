import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/schedule_controller.dart';
import '../../Widgets/SchedulePainter.dart';
import '../../Widgets/PageWrapper.dart';
import '../../services/schedule_service.dart';

class AdminScheduleScreen extends StatelessWidget {
  final scheduleController = Get.put(ScheduleController());

  AdminScheduleScreen({Key? key}) : super(key: key);

  Future<void> _showScheduleForm(BuildContext context,
      [ScheduleEntry? entry]) async {
    // Vérifier si les données nécessaires sont chargées
    if (scheduleController.teachers.isEmpty ||
        scheduleController.subjects.isEmpty ||
        scheduleController.classes.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez attendre le chargement des données (enseignants, matières et classes)',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    var selectedTeacherId =
        entry?.teacherId ?? (scheduleController.teachers[0]['id'] as int);
    var selectedSubjectId =
        entry?.subjectId ?? (scheduleController.subjects[0]['id'] as int);
    var selectedClassName = entry?.className ?? scheduleController.classes[0];
    final roomNumberCtrl = TextEditingController(text: entry?.roomNumber);
    String selectedDay = entry?.dayOfWeek ?? 'Monday';
    String selectedStartTime = entry?.startTime ?? '08:00';
    String selectedEndTime = entry?.endTime ?? '09:00';
    final endTimeCtrl = TextEditingController(text: selectedEndTime);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry == null ? 'Ajouter un cours' : 'Modifier le cours'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => DropdownButtonFormField<int>(
                      value: selectedTeacherId,
                      items: scheduleController.teachers
                          .map((teacher) => DropdownMenuItem(
                                value: teacher['id'] as int,
                                child: Text(
                                    '${teacher['first_name']} ${teacher['last_name']}'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) selectedTeacherId = value;
                      },
                      decoration:
                          const InputDecoration(labelText: 'Enseignant'),
                      validator: (value) =>
                          value == null ? 'Champ requis' : null,
                    )),
                Obx(() => DropdownButtonFormField<int>(
                      value: selectedSubjectId,
                      items: scheduleController.subjects
                          .map((subject) => DropdownMenuItem(
                                value: subject['id'] as int,
                                child: Text(subject['name'].toString()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) selectedSubjectId = value;
                      },
                      decoration: const InputDecoration(labelText: 'Matière'),
                      validator: (value) =>
                          value == null ? 'Champ requis' : null,
                    )),
                Obx(() => DropdownButtonFormField<String>(
                      value: selectedClassName,
                      items: scheduleController.classes
                          .map((className) => DropdownMenuItem(
                                value: className,
                                child: Text(className),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) selectedClassName = value;
                      },
                      decoration: const InputDecoration(labelText: 'Classe'),
                      validator: (value) =>
                          value == null ? 'Champ requis' : null,
                    )),
                TextFormField(
                  controller: roomNumberCtrl,
                  decoration: const InputDecoration(labelText: 'Salle'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Champ requis' : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  items: [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday'
                  ]
                      .map((day) =>
                          DropdownMenuItem(value: day, child: Text(day)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedDay = value;
                  },
                  decoration: const InputDecoration(labelText: 'Jour'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedStartTime,
                  items: [
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
                  ]
                      .map((time) =>
                          DropdownMenuItem(value: time, child: Text(time)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedStartTime = value;
                  },
                  decoration:
                      const InputDecoration(labelText: 'Heure de début'),
                ),
                TextFormField(
                  controller: endTimeCtrl,
                  readOnly: true,
                  onTap: () async {
                    final TimeOfDay currentTime = selectedEndTime != ''
                        ? TimeOfDay(
                            hour: int.parse(selectedEndTime.split(':')[0]),
                            minute: int.parse(selectedEndTime.split(':')[1]))
                        : TimeOfDay.now();

                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: currentTime,
                    );
                    if (picked != null) {
                      selectedEndTime =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      endTimeCtrl.text = selectedEndTime;
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Heure de fin'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Champ requis' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                if (entry == null) {
                  scheduleController.createSchedule(
                    teacherId: selectedTeacherId,
                    subjectId: selectedSubjectId,
                    className: selectedClassName,
                    dayOfWeek: selectedDay,
                    startTime: selectedStartTime,
                    endTime: selectedEndTime,
                    roomNumber: roomNumberCtrl.text,
                  );
                } else {
                  scheduleController.updateSchedule(
                    id: entry.id,
                    teacherId: selectedTeacherId,
                    subjectId: selectedSubjectId,
                    className: selectedClassName,
                    dayOfWeek: selectedDay,
                    startTime: selectedStartTime,
                    endTime: selectedEndTime,
                    roomNumber: roomNumberCtrl.text,
                  );
                }
                Navigator.of(context).pop();
              }
            },
            child: Text(entry == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Gestion des emplois du temps',
      showDrawer: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleForm(context),
        child: const Icon(Icons.add),
      ),
      child: Obx(() {
        if (scheduleController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SchedulePainter(
          schedules: scheduleController.schedules,
          isAdmin: true,
          onEdit: (entry) => _showScheduleForm(context, entry),
          onDelete: (id) => scheduleController.deleteSchedule(id),
        );
      }),
    );
  }
}
