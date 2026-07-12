import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';

class SignedInView extends StatelessWidget {
  const SignedInView({required this.email, required this.onSignOut, super.key});

  final String email;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(l10n.authSignedInAsLabel(email)),
        const VTGap.m(),
        OutlinedButton(onPressed: onSignOut, child: Text(l10n.authLogoutAction)),
      ],
    );
  }
}
