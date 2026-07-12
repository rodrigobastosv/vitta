import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

class SignedInView extends StatelessWidget {
  const SignedInView({required this.email, required this.onSignOut, super.key});

  final String email;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
