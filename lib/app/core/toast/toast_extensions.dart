import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_haptics.dart';
import 'package:vitta/app/design_system/components/general/vt_toast.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

const _successDuration = Duration(seconds: 4);
const _failureDuration = Duration(seconds: 6);
const _actionableFailureDuration = Duration(seconds: 8);

extension BuildContextToastExt on BuildContext {
  void showToast({required String title, required String message}) => _showToast(VTToast(title: title, message: message), _successDuration);

  void showErrorToast({required String message, String? title, VoidCallback? onRetry}) => _showToast(
    VTToast(
      title: title ?? l10n.errorTitle,
      message: message,
      severity: .error,
      actionLabel: onRetry == null ? null : l10n.retry,
      onAction: onRetry == null
          ? null
          : () {
              ScaffoldMessenger.of(this).hideCurrentSnackBar();
              onRetry();
            },
    ),
    onRetry == null ? _failureDuration : _actionableFailureDuration,
  );

  void showWarningToast({required String message, String? title}) =>
      _showToast(VTToast(title: title ?? l10n.warningTitle, message: message, severity: .warning), _failureDuration);

  void _showToast(VTToast toast, Duration duration) {
    switch (toast.severity) {
      case .success:
        VTHaptics.success();
      case .warning:
        VTHaptics.warning();
      case .error:
        VTHaptics.error();
    }
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: .floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.all(VTSpacing.m),
          duration: duration,
          clipBehavior: .none,
          content: toast,
        ),
      );
  }
}
