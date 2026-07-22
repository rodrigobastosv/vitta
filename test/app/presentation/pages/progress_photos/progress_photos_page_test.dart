import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo_pose.dart';
import 'package:vitta/app/presentation/general/list_skeleton.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photos_cubit.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photos_page.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/progress_photo_day_section.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/progress_photo_privacy_note.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/progress_photo_tile.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/progress_photo_factory.dart';
import '../../../../mocks/use_cases_mocks.dart';

Future<void> pumpProgressPhotosPage(
  WidgetTester tester, {
  List<ProgressPhoto> photos = const [],
  Duration loadDelay = Duration.zero,
}) async {
  final getProgressPhotosUseCase = MockGetProgressPhotosUseCase();
  when(getProgressPhotosUseCase.call).thenAnswer((_) async {
    await Future<void>.delayed(loadDelay);
    return Success(photos);
  });
  if (G.isRegistered<ProgressPhotosCubit>()) {
    G.unregister<ProgressPhotosCubit>();
  }
  G.registerFactory<ProgressPhotosCubit>(
    () => CubitsFactories.buildProgressPhotosCubit(getProgressPhotosUseCase: getProgressPhotosUseCase),
  );

  await tester.pumpWidget(
    MaterialApp.router(
      theme: VTTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (context, state) => const ProgressPhotosPage())],
      ),
      builder: (context, child) => LoaderOverlay(child: child!),
    ),
  );
}

void main() {
  testWidgets('shows the skeleton, not the empty state, while the first read is in flight', (tester) async {
    await pumpProgressPhotosPage(tester, loadDelay: const Duration(milliseconds: 200));
    await tester.pump();

    expect(find.byType(ListSkeleton), findsOneWidget);
    expect(find.byType(VTEmptyState), findsNothing);

    await tester.pumpAndSettle();
  });

  testWidgets('shows the empty state with no FAB once the read resolves empty', (tester) async {
    await pumpProgressPhotosPage(tester);
    await tester.pumpAndSettle();

    expect(find.byType(VTEmptyState), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('renders every shot taken on a day under that day, and offers the FAB', (tester) async {
    await pumpProgressPhotosPage(
      tester,
      photos: [
        ProgressPhotoFactory.build(id: 'a'),
        ProgressPhotoFactory.build(id: 'b', pose: ProgressPhotoPose.side),
        ProgressPhotoFactory.build(id: 'c', pose: ProgressPhotoPose.back),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProgressPhotoDaySection), findsOneWidget);
    expect(find.byType(ProgressPhotoTile), findsNWidgets(3));
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('states that the photos are private to the user', (tester) async {
    await pumpProgressPhotosPage(tester, photos: [ProgressPhotoFactory.build()]);
    await tester.pumpAndSettle();

    expect(find.byType(ProgressPhotoPrivacyNote), findsOneWidget);
    expect(find.text('Only you can see these'), findsOneWidget);
  });

  testWidgets('the compare action is disabled until there are two photos', (tester) async {
    await pumpProgressPhotosPage(tester, photos: [ProgressPhotoFactory.build()]);
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.compare_outlined)).onPressed, isNull);
  });
}
