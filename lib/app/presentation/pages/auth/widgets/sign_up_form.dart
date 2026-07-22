import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/inputs/vt_text_field.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';
import 'package:vitta/app/presentation/pages/auth/widgets/avatar_picker.dart';

typedef SignUpSubmit = Future<void> Function({required String email, required String password, String? displayName});

class SignUpForm extends StatefulWidget {
  const SignUpForm({required this.state, required this.onSubmit, required this.onGoToSignIn, super.key});

  final AuthState state;
  final SignUpSubmit onSubmit;
  final VoidCallback onGoToSignIn;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await widget.onSubmit(email: _emailController.text.trim(), password: _passwordController.text, displayName: _nameController.text.trim());
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
          Text(l10n.signUpTitle, style: VTTextStyles.title(context)),
          const VTGap.xs(),
          Text(l10n.authAnonymousMessage, style: VTTextStyles.caption(context)),
          const VTGap.l(),
          AvatarPicker(state: widget.state),
          const VTGap.l(),
          VTTextField(
            controller: _nameController,
            label: l10n.authDisplayNameLabel,
            prefixIcon: Icons.person_outline,
            textCapitalization: .words,
            textInputAction: .next,
            autofillHints: const [AutofillHints.name],
            onSubmitted: _emailFocus.requestFocus,
          ),
          const VTGap.s(),
          VTTextField(
            controller: _emailController,
            focusNode: _emailFocus,
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
            autofillHints: const [AutofillHints.newPassword],
            onSubmitted: _submit,
            validator: (value) => value != null && value.length >= 6 ? null : l10n.authInvalidPasswordMessage,
          ),
          const VTGap.l(),
          VTPrimaryButton(label: l10n.authSignUpAction, onPressed: _submit),
          const VTGap.s(),
          Center(
            child: TextButton(onPressed: widget.onGoToSignIn, child: Text(l10n.authHasAccountAction)),
          ),
        ],
      ),
    );
  }
}
