import 'package:flutter/material.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_capture_boundary.dart';
import 'package:vitta/app/design_system/components/general/vt_capture_controller.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/trends/entities/progress_story.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/share_progress/share_progress_cubit.dart';
import 'package:vitta/app/presentation/pages/share_progress/share_progress_presentation_event.dart';
import 'package:vitta/app/presentation/pages/share_progress/share_progress_state.dart';
import 'package:vitta/app/presentation/pages/share_progress/widgets/progress_story_card.dart';

class ShareProgressPage extends StatefulWidget {
  const ShareProgressPage({required this.story, super.key});

  final ProgressStory story;

  @override
  State<ShareProgressPage> createState() => _ShareProgressPageState();
}

class _ShareProgressPageState extends State<ShareProgressPage> {
  final VTCaptureController _captureController = VTCaptureController();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<ShareProgressCubit, ShareProgressState, ShareProgressPresentationEvent>(
      cubitParam: widget.story,
      onPresentation: (context, event) {
        switch (event) {
          case ShareProgressShowLoading():
            context.showLoading();
          case ShareProgressHideLoading():
            context.hideLoading();
          case ShareProgressFailed():
            context.showErrorToast(message: l10n.shareProgressFailed);
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.shareProgressTitle)),
        // The card is a fixed 9:16 so the exported image is the same size on
        // every device; the FittedBox is what fits it to this screen. Scaling the
        // card itself would make the export's resolution a property of whatever
        // phone took it.
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(VTSpacing.m),
            child: FittedBox(
              child: VTCaptureBoundary(
                controller: _captureController,
                child: ProgressStoryCard(story: state.story, unitSystem: cubit.unitSystem),
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(VTSpacing.m),
          child: VTPrimaryButton(
            label: l10n.shareProgressAction,
            icon: Icons.ios_share,
            onPressed: () => cubit.share(captureImage: _captureController.capture, message: l10n.shareProgressMessage(state.story.days)),
          ),
        ),
      ),
    );
  }
}
