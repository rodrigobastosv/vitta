import 'package:flutter/material.dart';
import 'package:vitta/app/presentation/pages/diet/widgets/diet_intro_view.dart';

class DietIntroPage extends StatelessWidget {
  const DietIntroPage({super.key});

  @override
  Widget build(BuildContext context) => DietIntroView(onSetGoals: () => Navigator.of(context).pop(true), onSkip: () => Navigator.of(context).pop(false));
}
