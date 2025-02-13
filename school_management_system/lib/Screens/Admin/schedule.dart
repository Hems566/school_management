import 'package:flutter/material.dart';
import 'package:school_management/Widgets/PageWrapper.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Emploi du temps',
      showDrawer: true,
      child: Center(
        child: Text(
          'Page de gestion des emplois du temps en construction...',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
