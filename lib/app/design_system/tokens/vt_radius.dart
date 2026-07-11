import 'package:flutter/widgets.dart';

abstract class VTRadius {
  static const double s = 8;
  static const double m = 12;
  static const double l = 20;
  static const double full = 999;

  static const BorderRadius borderRadiusS = BorderRadius.all(Radius.circular(s));
  static const BorderRadius borderRadiusM = BorderRadius.all(Radius.circular(m));
  static const BorderRadius borderRadiusL = BorderRadius.all(Radius.circular(l));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(full));
}
