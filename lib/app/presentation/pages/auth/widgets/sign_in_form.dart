import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

typedef SignInSubmit = Future<void> Function({required String email, required String password});

class SignInForm extends StatefulWidget {
  const SignInForm({required this.onSubmit, required this.onGoToSignUp, super.key});

  final SignInSubmit onSubmit;
  final VoidCallback onGoToSignUp;

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await widget.onSubmit(email: _emailController.text.trim(), password: _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(l10n.signInTitle, style: VTTextStyles.title(context)),
          const VTGap.l(),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: l10n.authEmailLabel),
            validator: (value) => value != null && value.contains('@') ? null : l10n.authInvalidEmailMessage,
          ),
          const VTGap.s(),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.authPasswordLabel),
            validator: (value) => value != null && value.length >= 6 ? null : l10n.authInvalidPasswordMessage,
          ),
          const VTGap.l(),
          VTPrimaryButton(label: l10n.authSignInAction, onPressed: _submit),
          const VTGap.s(),
          Center(
            child: TextButton(onPressed: widget.onGoToSignUp, child: Text(l10n.authNoAccountAction)),
          ),
        ],
      ),
    );
  }
}
