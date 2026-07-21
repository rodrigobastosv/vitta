import 'package:flutter/material.dart';

abstract class VTMotion {
  static const Curve curve = Curves.easeOutCubic;

  static const Duration micro = Duration(milliseconds: 150);
  static const Duration transition = Duration(milliseconds: 250);
  static const Duration entrance = Duration(milliseconds: 400);
  static const Duration data = Duration(milliseconds: 800);

  static const Duration staggerStep = Duration(milliseconds: 60);
  static const int maxStaggerSteps = 6;

  static Duration staggerFor(int index) => staggerStep * index.clamp(0, maxStaggerSteps);
}
