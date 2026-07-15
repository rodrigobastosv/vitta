import 'package:flutter/material.dart';

class VTSearchField extends StatefulWidget {
  const VTSearchField({required this.hintText, required this.onSubmitted, this.text, this.autofocus = false, super.key});

  final String hintText;
  final ValueChanged<String> onSubmitted;

  /// The query the field should show. Only a *change* to this value is pushed
  /// into the field, so a caller that replays a past search fills the box while
  /// ordinary typing is never clobbered mid-word.
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
    onChanged: (_) => setState(() {}),
    onSubmitted: widget.onSubmitted,
    decoration: InputDecoration(
      hintText: widget.hintText,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: _controller.text.isEmpty ? null : IconButton(icon: const Icon(Icons.close), onPressed: _clear),
    ),
  );
}
