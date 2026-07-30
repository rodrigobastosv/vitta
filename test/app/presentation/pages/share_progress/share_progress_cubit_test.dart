import 'dart:typed_data';

import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/services/share/share_outcome.dart';
import 'package:vitta/app/domain/trends/entities/area_trend.dart';
import 'package:vitta/app/domain/trends/entities/progress_story.dart';
import 'package:vitta/app/presentation/pages/share_progress/share_progress_cubit.dart';
import 'package:vitta/app/presentation/pages/share_progress/share_progress_presentation_event.dart';
import 'package:vitta/app/presentation/pages/share_progress/share_progress_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/services_mocks.dart';

ProgressStory buildStory() => ProgressStory(
  days: 30,
  trends: {
    .nutrition: AreaTrend(days: [DateTime(2026, 7, 20)], valuesByDate: {DateTime(2026, 7, 20): 2000}, goal: 2000),
    .water: AreaTrend(days: [DateTime(2026, 7, 20)], valuesByDate: {DateTime(2026, 7, 20): 500}, goal: 2000),
  },
);

Uint8List storyImage() => Uint8List.fromList([1, 2, 3]);

MockShareService stubbedShareService(ShareOutcome outcome) {
  final shareService = MockShareService();
  when(
    () => shareService.shareImage(bytes: any(named: 'bytes'), fileName: any(named: 'fileName'), message: any(named: 'message')),
  ).thenAnswer((_) async => outcome);
  return shareService;
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  group('share', () {
    test('hands the captured image and the caller message to the share sheet', () async {
      final shareService = stubbedShareService(.shared);
      final cubit = CubitsFactories.buildShareProgressCubit(story: buildStory(), shareService: shareService);

      await cubit.share(captureImage: () async => storyImage(), message: 'My last 30 days on Vitta.');

      verify(
        () => shareService.shareImage(bytes: storyImage(), fileName: any(named: 'fileName'), message: 'My last 30 days on Vitta.'),
      ).called(1);
    });

    test('logs the period and how it went, never what was tracked', () async {
      final loggingService = useMockLog();
      final shareService = stubbedShareService(.shared);
      final cubit = CubitsFactories.buildShareProgressCubit(story: buildStory(), shareService: shareService);

      await cubit.share(captureImage: () async => storyImage(), message: 'message');

      final captured = verify(() => loggingService.logAction(captureAny(), data: captureAny(named: 'data'))).captured;
      expect(captured, [
        'progress_shared',
        {'days': 30, 'areas': 2, 'judged_areas': 2, 'on_track_areas': 1},
      ]);
    });

    test('a dismissed share sheet is neither logged nor reported as a failure', () async {
      final loggingService = useMockLog();
      final shareService = stubbedShareService(.dismissed);
      final cubit = CubitsFactories.buildShareProgressCubit(story: buildStory(), shareService: shareService);

      await cubit.share(captureImage: () async => storyImage(), message: 'message');

      verifyNever(() => loggingService.logAction(any(), data: any(named: 'data')));
    });

    blocPresentationTest<ShareProgressCubit, ShareProgressState, ShareProgressPresentationEvent>(
      'brackets the capture and the share sheet with the overlay',
      build: () => CubitsFactories.buildShareProgressCubit(story: buildStory(), shareService: stubbedShareService(.shared)),
      act: (cubit) => cubit.share(captureImage: () async => storyImage(), message: 'message'),
      expectPresentation: () => [isA<ShareProgressShowLoading>(), isA<ShareProgressHideLoading>()],
    );

    blocPresentationTest<ShareProgressCubit, ShareProgressState, ShareProgressPresentationEvent>(
      'reports a failure when the card could not be captured',
      build: () => CubitsFactories.buildShareProgressCubit(story: buildStory(), shareService: stubbedShareService(.shared)),
      act: (cubit) => cubit.share(captureImage: () async => null, message: 'message'),
      expectPresentation: () => [isA<ShareProgressShowLoading>(), isA<ShareProgressHideLoading>(), isA<ShareProgressFailed>()],
    );

    blocPresentationTest<ShareProgressCubit, ShareProgressState, ShareProgressPresentationEvent>(
      'reports a failure when the share sheet itself failed',
      build: () => CubitsFactories.buildShareProgressCubit(story: buildStory(), shareService: stubbedShareService(.failed)),
      act: (cubit) => cubit.share(captureImage: () async => storyImage(), message: 'message'),
      expectPresentation: () => [isA<ShareProgressShowLoading>(), isA<ShareProgressHideLoading>(), isA<ShareProgressFailed>()],
    );

    test('never asks the share sheet for anything when the capture came back empty', () async {
      final shareService = stubbedShareService(.shared);
      final cubit = CubitsFactories.buildShareProgressCubit(story: buildStory(), shareService: shareService);

      await cubit.share(captureImage: () async => null, message: 'message');

      verifyNever(() => shareService.shareImage(bytes: any(named: 'bytes'), fileName: any(named: 'fileName'), message: any(named: 'message')));
    });
  });
}
