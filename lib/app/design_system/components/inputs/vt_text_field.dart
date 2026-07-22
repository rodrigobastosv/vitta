import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';

// The app's text input: it leans on VTTheme's inputDecorationTheme (filled, rounded,
// borderless) and adds the pieces a raw TextFormField leaves to each call site — a
// leading icon, keyboard-action chaining, and a built-in password-reveal toggle so
// obscured fields aren't a dead end.
class VTTextField extends StatefulWidget {
  const VTTextField({
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.obscurable = false,
    this.textInputAction,
    this.focusNode,
    this.onSubmitted,
    this.validator,
    this.autofillHints,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  // When true the field starts obscured and shows a reveal toggle.
  final bool obscurable;

  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<String>? autofillHints;

  @override
  State<VTTextField> createState() => _VTTextFieldState();
}

class _VTTextFieldState extends State<VTTextField> {
  late bool _obscured = widget.obscurable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      obscureText: _obscured,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onFieldSubmitted: widget.onSubmitted == null ? null : (_) => widget.onSubmitted!(),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
        suffixIcon: widget.obscurable
            ? IconButton(
                icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                tooltip: _obscured ? l10n.passwordShow : l10n.passwordHide,
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }
}
