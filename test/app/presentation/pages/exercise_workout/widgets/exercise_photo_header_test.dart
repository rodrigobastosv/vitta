import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/pages/exercise_workout/widgets/exercise_photo_header.dart';

Future<void> pumpHeader(WidgetTester tester, List<String> imageUrls) => tester.pumpWidget(
  MaterialApp(
    theme: VTTheme.light,
    home: Scaffold(
      body: SizedBox(height: 280, child: ExercisePhotoHeader(imageUrls: imageUrls)),
    ),
  ),
);

void main() {
  testWidgets('keeps every photo, swipeable, with dots saying how many there are', (tester) async {
    await pumpHeader(tester, const ['a.png', 'b.png', 'c.png']);

    expect(find.byType(PageView), findsOneWidget);
    expect(tester.widget<PageView>(find.byType(PageView)).childrenDelegate.estimatedChildCount, 3);
    expect(find.byType(AnimatedContainer), findsNWidgets(3));
  });

  testWidgets('the scrim does not swallow the swipe that changes photo', (tester) async {
    await pumpHeader(tester, const ['a.png', 'b.png', 'c.png']);

    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();

    final controller = tester.widget<PageView>(find.byType(PageView)).controller!;
    expect(controller.page?.round(), 1, reason: 'a gradient painted over the PageView must not absorb pointers');
  });

  testWidgets('a single photo needs no dots', (tester) async {
    await pumpHeader(tester, const ['only.png']);

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(AnimatedContainer), findsNothing);
  });

  testWidgets('an exercise with no photos still paints a header rather than a gap', (tester) async {
    await pumpHeader(tester, const []);

    expect(find.byType(PageView), findsNothing);
    expect(find.byType(DecoratedBox), findsWidgets);
  });
}
