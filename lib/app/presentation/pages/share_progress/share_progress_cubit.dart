import 'dart:typed_data';

import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/core/services/share/share_outcome.dart';
import 'package:vitta/app/core/services/share/share_service.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/domain/settings/use_cases/get_app_settings_use_case.dart';
import 'package:vitta/app/domain/trends/entities/progress_story.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/share_progress/share_progress_presentation_event.dart';
import 'package:vitta/app/presentation/pages/share_progress/share_progress_state.dart';

typedef CaptureStoryImage = Future<Uint8List?> Function();

class ShareProgressCubit extends PresentationCubit<ShareProgressState, ShareProgressPresentationEvent> {
  ShareProgressCubit({required ProgressStory story, required this._shareService, required this._getAppSettingsUseCase})
    : super(ShareProgressState(story: story));

  final ShareService _shareService;
  final GetAppSettingsUseCase _getAppSettingsUseCase;

  static const String _fileName = 'vitta-progress.png';

  UnitSystem get unitSystem => _getAppSettingsUseCase().unitSystem;

  /// Takes the capture as a callback rather than the bytes, so the wait the user
  /// sees covers rendering the image as well as the share sheet opening — the
  /// encode is the slow half, and the cubit stays free of widgets.
  Future<void> share({required CaptureStoryImage captureImage, required String message}) async {
    final outcome = await withLoadingOverlay(
      () => _shareImage(captureImage, message),
      showOverlay: true,
      showLoadingEvent: ShareProgressShowLoading(),
      hideLoadingEvent: ShareProgressHideLoading(),
    );
    switch (outcome) {
      case .shared:
        Log.action(
          'progress_shared',
          data: {
            'days': state.story.days,
            'areas': state.story.areasWithData.length,
            'judged_areas': state.story.judgedAreaCount,
            'on_track_areas': state.story.onTrackAreaCount,
          },
        );
      case .dismissed:
        break;
      case .failed:
        emitPresentation(ShareProgressFailed());
    }
  }

  Future<ShareOutcome> _shareImage(CaptureStoryImage captureImage, String message) async {
    final imageBytes = await captureImage();
    if (imageBytes == null) {
      return .failed;
    }
    return _shareService.shareImage(bytes: imageBytes, fileName: _fileName, message: message);
  }
}
