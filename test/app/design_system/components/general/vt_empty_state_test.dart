import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

Future<void> pumpEmptyState(WidgetTester tester, VTEmptyState emptyState) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    home: Scaffold(body: emptyState),
  ),
);

void main() {
  testWidgets('offers its call to action when one is given', (tester) async {
    var taps = 0;
    await pumpEmptyState(
      tester,
      VTEmptyState(
        icon: Icons.restaurant_outlined,
        title: 'No meals logged yet',
        message: 'Add what you ate.',
        actionLabel: 'Log a meal',
        onAction: () => taps++,
      ),
    );

    await tester.tap(find.text('Log a meal'));
    expect(taps, 1);
  });

  testWidgets('renders no button when there is nothing to offer', (tester) async {
    await pumpEmptyState(tester, const VTEmptyState(icon: Icons.restaurant_outlined, message: 'Nothing here.'));

    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('a label with no callback stays inert rather than rendering a dead button', (tester) async {
    await pumpEmptyState(tester, const VTEmptyState(icon: Icons.restaurant_outlined, message: 'Nothing here.', actionLabel: 'Log a meal'));

    expect(find.text('Log a meal'), findsNothing);
  });
}
