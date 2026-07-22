import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/inputs/vt_text_field.dart';
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
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
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
          VTTextField(
            controller: _emailController,
            label: l10n.authEmailLabel,
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: .next,
            autofillHints: const [AutofillHints.email],
            onSubmitted: _passwordFocus.requestFocus,
            validator: (value) => value != null && value.contains('@') ? null : l10n.authInvalidEmailMessage,
          ),
          const VTGap.s(),
          VTTextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            label: l10n.authPasswordLabel,
            prefixIcon: Icons.lock_outline,
            obscurable: true,
            textInputAction: .done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: _submit,
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
