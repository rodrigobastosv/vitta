import 'package:flutter/material.dart';

class VTSearchField extends StatefulWidget {
  const VTSearchField({required this.hintText, required this.onSubmitted, this.autofocus = false, super.key});

  final String hintText;
  final ValueChanged<String> onSubmitted;
  final bool autofocus;

  @override
  State<VTSearchField> createState() => _VTSearchFieldState();
}

class _VTSearchFieldState extends State<VTSearchField> {
  final _controller = TextEditingController();

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
