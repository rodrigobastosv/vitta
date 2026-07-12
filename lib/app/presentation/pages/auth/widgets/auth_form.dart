import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

typedef AuthAction = Future<void> Function({required String email, required String password});

class AuthForm extends StatefulWidget {
  const AuthForm({required this.initialIsSignUp, required this.onSignUp, required this.onSignIn, super.key});

  final bool initialIsSignUp;
  final AuthAction onSignUp;
  final AuthAction onSignIn;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  late bool _isSignUp = widget.initialIsSignUp;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.authInvalidEmailMessage)));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.authInvalidPasswordMessage)));
      return;
    }

    _isSignUp ? await widget.onSignUp(email: email, password: password) : await widget.onSignIn(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Text(l10n.authAnonymousMessage),
        const VTGap.m(),
        Text(_isSignUp ? l10n.authCreateAction : l10n.authLoginAction, style: VTTextStyles.title(context)),
        const VTGap.m(),
        Wrap(
          spacing: VTSpacing.s,
          children: [
            ChoiceChip(label: Text(l10n.authSignUpAction), selected: _isSignUp, onSelected: (_) => setState(() => _isSignUp = true)),
            ChoiceChip(label: Text(l10n.authSignInAction), selected: !_isSignUp, onSelected: (_) => setState(() => _isSignUp = false)),
          ],
        ),
        const VTGap.l(),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: l10n.authEmailLabel),
        ),
        const VTGap.s(),
        TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: l10n.authPasswordLabel)),
        const VTGap.l(),
        VTPrimaryButton(label: _isSignUp ? l10n.authSignUpAction : l10n.authSignInAction, onPressed: _submit),
      ],
    );
  }
}
