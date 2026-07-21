import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_drag_handle.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

void main() {
  testWidgets('the drag handle clears the minimum tap target in both directions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: VTTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: Center(child: VTDragHandle())),
      ),
    );

    final size = tester.getSize(find.byType(VTDragHandle));
    expect(size.width, greaterThanOrEqualTo(VTSpacing.minTapTarget));
    expect(size.height, greaterThanOrEqualTo(VTSpacing.minTapTarget));
  });
}
