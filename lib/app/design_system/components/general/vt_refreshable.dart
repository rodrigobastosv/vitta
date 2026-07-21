import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

class VTRefreshable extends StatelessWidget {
  const VTRefreshable({
    required this.onRefresh,
    required this.children,
    this.hasData = true,
    this.emptyState,
    this.padding = const EdgeInsets.all(VTSpacing.m),
    super.key,
  }) : assert(hasData || emptyState != null, 'A screen without data needs an emptyState to show instead of a blank list.');

  final Future<void> Function() onRefresh;
  final List<Widget> children;
  final bool hasData;
  final Widget? emptyState;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: switch (emptyState) {
      final emptyState? when !hasData => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: emptyState,
          ),
        ),
      ),
      _ => ListView(physics: const AlwaysScrollableScrollPhysics(), padding: padding, children: children),
    },
  );
}
