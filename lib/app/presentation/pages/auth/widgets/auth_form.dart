import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

typedef AuthModeChanged = void Function({required bool isSignUp});
typedef AuthSubmitAction = Future<void> Function({required String email, required String password});

class AuthForm extends StatefulWidget {
  const AuthForm({required this.isSignUp, required this.onModeChanged, required this.onSubmit, super.key});

  final bool isSignUp;
  final AuthModeChanged onModeChanged;
  final AuthSubmitAction onSubmit;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
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
    final isSignUp = widget.isSignUp;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(l10n.authAnonymousMessage),
          const VTGap.m(),
          Text(isSignUp ? l10n.authCreateAction : l10n.authLoginAction, style: VTTextStyles.title(context)),
          const VTGap.m(),
          Wrap(
            spacing: VTSpacing.s,
            children: [
              ChoiceChip(label: Text(l10n.authSignUpAction), selected: isSignUp, onSelected: (_) => widget.onModeChanged(isSignUp: true)),
              ChoiceChip(label: Text(l10n.authSignInAction), selected: !isSignUp, onSelected: (_) => widget.onModeChanged(isSignUp: false)),
            ],
          ),
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
          VTPrimaryButton(label: isSignUp ? l10n.authSignUpAction : l10n.authSignInAction, onPressed: _submit),
        ],
      ),
    );
  }
}
