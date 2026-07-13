import 'package:flutter/material.dart';

class MealAvatar extends StatelessWidget {
  const MealAvatar({required this.icon, required this.color, super.key});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(color: color.withValues(alpha: 0.16), shape: .circle),
    child: Icon(icon, color: color, size: 22),
  );
}
