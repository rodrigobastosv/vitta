import 'package:flutter/services.dart';

abstract final class VTHaptics {
  static const Duration alarmPulseGap = Duration(milliseconds: 160);
  static const int alarmPulses = 3;

  static Future<void> selection() => HapticFeedback.selectionClick();

  static Future<void> success() => HapticFeedback.lightImpact();

  static Future<void> countdown() => HapticFeedback.mediumImpact();

  static Future<void> alarm() async {
    for (var pulse = 0; pulse < alarmPulses; pulse++) {
      if (pulse > 0) {
        await Future<void>.delayed(alarmPulseGap);
      }
      await HapticFeedback.heavyImpact();
    }
  }

  static Future<void> warning() => HapticFeedback.mediumImpact();

  static Future<void> error() => HapticFeedback.heavyImpact();

  static Future<void> drag() => HapticFeedback.mediumImpact();
}
