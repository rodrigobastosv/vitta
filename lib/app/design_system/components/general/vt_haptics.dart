import 'package:flutter/services.dart';

abstract final class VTHaptics {
  static Future<void> selection() => HapticFeedback.selectionClick();

  static Future<void> success() => HapticFeedback.lightImpact();

  static Future<void> warning() => HapticFeedback.mediumImpact();

  static Future<void> error() => HapticFeedback.heavyImpact();

  static Future<void> drag() => HapticFeedback.mediumImpact();
}
