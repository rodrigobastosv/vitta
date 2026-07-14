import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_toast.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

extension BuildContextToastExt on BuildContext {
  void showToast({required String title, required String message, IconData icon = Icons.check_circle_rounded, Color? accentColor}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: .floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.all(VTSpacing.m),
          content: VTToast(title: title, message: message, icon: icon, accentColor: accentColor),
        ),
      );
  }
}
