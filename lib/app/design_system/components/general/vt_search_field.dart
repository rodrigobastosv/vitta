import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';

class VTSearchField extends StatefulWidget {
  const VTSearchField({required this.hintText, required this.onSubmitted, this.onChanged, this.text, this.autofocus = false, super.key});

  final String hintText;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;

  final String? text;

  final bool autofocus;

  @override
  State<VTSearchField> createState() => _VTSearchFieldState();
}

class _VTSearchFieldState extends State<VTSearchField> {
  late final _controller = TextEditingController(text: widget.text);

  @override
  void didUpdateWidget(VTSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text && widget.text != _controller.text) {
      _controller.text = widget.text ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onSubmitted('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    autofocus: widget.autofocus,
    textInputAction: .search,
    onChanged: (value) {
      setState(() {});
      widget.onChanged?.call(value);
    },
    onSubmitted: widget.onSubmitted,
    decoration: InputDecoration(
      hintText: widget.hintText,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: _controller.text.isEmpty ? null : IconButton(icon: const Icon(Icons.close), tooltip: context.l10n.clearSearch, onPressed: _clear),
    ),
  );
}
