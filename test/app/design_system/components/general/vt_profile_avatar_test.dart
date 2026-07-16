import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_avatar_catalog.dart';
import 'package:vitta/app/design_system/components/general/vt_profile_avatar.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';

Future<void> pump(WidgetTester tester, VTProfileAvatar avatar) =>
    tester.pumpWidget(MaterialApp(theme: VTTheme.light, home: Scaffold(body: Center(child: avatar))));

void main() {
  testWidgets('a chosen preset renders its catalog icon', (tester) async {
    await pump(tester, const VTProfileAvatar(avatarId: 'leaf', initial: 'R'));

    expect(find.byIcon(VTAvatarCatalog.byId('leaf')!.icon), findsOneWidget);
    expect(find.text('R'), findsNothing);
  });

  testWidgets('with no photo or preset it falls back to the initial', (tester) async {
    await pump(tester, const VTProfileAvatar(initial: 'R'));

    expect(find.text('R'), findsOneWidget);
  });

  testWidgets('with nothing at all it shows the person icon', (tester) async {
    await pump(tester, const VTProfileAvatar());

    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });
}
