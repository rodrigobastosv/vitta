import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';

class VTRefreshable extends StatelessWidget {
  const VTRefreshable({
    required this.onRefresh,
    required this.children,
    this.hasData = true,
    this.isLoaded = true,
    this.emptyState,
    this.skeleton,
    this.padding = const EdgeInsets.all(VTSpacing.m),
    super.key,
  }) : assert(hasData || emptyState != null, 'A screen without data needs an emptyState to show instead of a blank list.'),
       assert(isLoaded || skeleton != null, 'A screen still loading needs a skeleton, or it flashes its empty state first.');

  final Future<void> Function() onRefresh;
  final List<Widget> children;
  final bool hasData;
  final bool isLoaded;
  final Widget? emptyState;
  final Widget? skeleton;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: switch ((skeleton, emptyState)) {
      (final skeleton?, _) when !isLoaded => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: [skeleton],
      ),
      (_, final emptyState?) when !hasData => LayoutBuilder(
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
