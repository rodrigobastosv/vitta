import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/presentation/pages/progress_photo_compare/progress_photo_compare_page.dart';
import 'package:vitta/app/presentation/pages/progress_photo_compare/widgets/progress_photo_compare_slot.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/entities/progress_photo_factory.dart';

Future<void> pumpComparePage(WidgetTester tester, List<ProgressPhoto> photos) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ProgressPhotoComparePage(photos: photos),
  ),
);

ProgressPhoto beforePhoto(WidgetTester tester) =>
    tester.widget<ProgressPhotoCompareSlot>(find.byType(ProgressPhotoCompareSlot).first).photo;

ProgressPhoto afterPhoto(WidgetTester tester) =>
    tester.widget<ProgressPhotoCompareSlot>(find.byType(ProgressPhotoCompareSlot).last).photo;

void main() {
  testWidgets('pairs the oldest and newest shot of the same pose, never across poses', (tester) async {
    await pumpComparePage(tester, [
      ProgressPhotoFactory.build(id: 'front-new', takenDate: DateTime(2026, 7, 18)),
      ProgressPhotoFactory.build(id: 'back-new', takenDate: DateTime(2026, 7, 18), pose: .back),
      ProgressPhotoFactory.build(id: 'front-old', takenDate: DateTime(2026, 5, 2)),
    ]);
    await tester.pumpAndSettle();

    expect(beforePhoto(tester).id, 'front-old');
    expect(afterPhoto(tester).id, 'front-new');
  });

  testWidgets('switching pose re-pairs both slots within that pose', (tester) async {
    await pumpComparePage(tester, [
      ProgressPhotoFactory.build(id: 'front-new', takenDate: DateTime(2026, 7, 18)),
      ProgressPhotoFactory.build(id: 'front-old', takenDate: DateTime(2026, 5, 2)),
      ProgressPhotoFactory.build(id: 'back-new', takenDate: DateTime(2026, 7, 18), pose: .back),
      ProgressPhotoFactory.build(id: 'back-old', takenDate: DateTime(2026, 5, 2), pose: .back),
    ]);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Back'));
    await tester.pumpAndSettle();

    expect(beforePhoto(tester).id, 'back-old');
    expect(afterPhoto(tester).id, 'back-new');
  });

  testWidgets('a selected pose keeps its own glyph, with no checkmark drawn over it', (tester) async {
    await pumpComparePage(tester, [
      ProgressPhotoFactory.build(id: 'front-new', takenDate: DateTime(2026, 7, 18)),
      ProgressPhotoFactory.build(id: 'front-old', takenDate: DateTime(2026, 5, 2)),
    ]);
    await tester.pumpAndSettle();

    final chip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Front'));
    expect(chip.selected, isTrue);
    expect(chip.showCheckmark, isFalse);
  });

  testWidgets('offers only the poses that have a photo', (tester) async {
    await pumpComparePage(tester, [
      ProgressPhotoFactory.build(id: 'front-new', takenDate: DateTime(2026, 7, 18)),
      ProgressPhotoFactory.build(id: 'front-old', takenDate: DateTime(2026, 5, 2)),
    ]);
    await tester.pumpAndSettle();

    expect(find.byType(ChoiceChip), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Front'), findsOneWidget);
  });
}
