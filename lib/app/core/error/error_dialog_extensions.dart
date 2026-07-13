import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_error_dialog.dart';

extension BuildContextErrorDialogExt on BuildContext {
  Future<void> showErrorDialog({required String message, VoidCallback? onRetry}) => showDialog<void>(
    context: this,
    builder: (_) => VTErrorDialog(message: message, onRetry: onRetry),
  );
}
