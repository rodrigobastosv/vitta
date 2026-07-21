import 'package:flutter/material.dart';
import 'package:vitta/app/presentation/pages/workout/widgets/workout_intro_view.dart';

class WorkoutIntroPage extends StatelessWidget {
  const WorkoutIntroPage({super.key});

  @override
  Widget build(BuildContext context) =>
      WorkoutIntroView(onCreateRoutine: () => Navigator.of(context).pop(true), onSkip: () => Navigator.of(context).pop(false));
}
