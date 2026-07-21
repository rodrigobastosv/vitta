import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

Future<bool> showDeleteAccountConfirmation({required BuildContext context}) async {
  final confirmed = await showDialog<bool>(context: context, builder: (context) => const DeleteAccountDialog());
  return confirmed ?? false;
}

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    return AlertDialog(
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: colorScheme.errorContainer, shape: .circle),
        child: Icon(Icons.delete_forever_outlined, color: colorScheme.onErrorContainer),
      ),
      title: Text(l10n.deleteAccountDialogTitle),
      content: Text(l10n.deleteAccountDialogMessage, textAlign: .center),
      actionsAlignment: .center,
      actions: [
        Column(
          children: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: colorScheme.error, foregroundColor: colorScheme.onError, minimumSize: const Size.fromHeight(48)),
              child: Text(l10n.deleteAccountConfirmAction),
            ),
            const VTGap.xs(),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(minimumSize: const Size.fromHeight(VTSpacing.xxl)),
              child: Text(l10n.cancelAction),
            ),
          ],
        ),
      ],
    );
  }
}
