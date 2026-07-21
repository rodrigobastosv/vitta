import 'package:flutter/material.dart';

class VTSemanticSummary extends StatelessWidget {
  const VTSemanticSummary({required this.label, required this.child, super.key});

  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) => switch (label) {
    final label? => Semantics(label: label, excludeSemantics: true, container: true, child: child),
    null => child,
  };
}
