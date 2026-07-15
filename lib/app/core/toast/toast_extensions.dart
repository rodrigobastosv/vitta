import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_toast.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

/// A success is an acknowledgement you can miss without cost. A failure isn't,
/// so it stays up longer - and longer still when there's a retry to aim at.
const _successDuration = Duration(seconds: 4);
const _failureDuration = Duration(seconds: 6);
const _actionableFailureDuration = Duration(seconds: 8);

extension BuildContextToastExt on BuildContext {
  void showToast({required String title, required String message}) =>
      _showToast(VTToast(title: title, message: message), _successDuration);

  /// A failure the user didn't cause. `onRetry` becomes an action on the toast
  /// itself, so the choice the dialog used to block the screen to ask is still
  /// offered - just not in the way.
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

  /// A failure the user can fix from where they already are - an empty field, a
  /// scan that read nothing. Deliberately has no retry: running the same
  /// incomplete form again fails the same way.
  void showWarningToast({required String message, String? title}) =>
      _showToast(VTToast(title: title ?? l10n.warningTitle, message: message, severity: .warning), _failureDuration);

  void _showToast(VTToast toast, Duration duration) {
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
          // SnackBar clips hard to its own radius-4 shape by default. With zero
          // padding its bounds are the toast's bounds, so it sliced the toast's
          // shadow off flush with the corners - which reads as a grey border
          // drawn around the card rather than as a shadow at all.
          clipBehavior: .none,
          content: toast,
        ),
      );
  }
}
