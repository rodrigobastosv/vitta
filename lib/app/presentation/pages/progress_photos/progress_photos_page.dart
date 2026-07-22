import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_empty_state.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_image_source_sheet.dart';
import 'package:vitta/app/design_system/components/general/vt_refreshable.dart';
import 'package:vitta/app/presentation/general/list_skeleton.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/progress_photo_compare/progress_photo_compare_extra.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photos_cubit.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photos_presentation_event.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photos_state.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/add_progress_photo_sheet.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/progress_photo_month_section.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/progress_photo_privacy_note.dart';
import 'package:vitta/app/presentation/pages/progress_photos/widgets/progress_photo_viewer_dialog.dart';

class ProgressPhotosPage extends StatelessWidget {
  const ProgressPhotosPage({super.key});

  static Future<void> _addPhoto(BuildContext context) async {
    final cubit = context.read<ProgressPhotosCubit>();
    final source = await showImageSourceSheet(context: context);
    if (source == null) {
      return;
    }
    await cubit.pickPhoto(source: source);
  }

  @override
  Widget build(BuildContext context) => VTPage<ProgressPhotosCubit, ProgressPhotosState, ProgressPhotosPresentationEvent>(
    onPresentation: (context, event) {
      final l10n = context.l10n;
      switch (event) {
        case ProgressPhotosShowLoading():
          context.showLoading();
        case ProgressPhotosHideLoading():
          context.hideLoading();
        case ProgressPhotosError(:final message):
          context.showErrorToast(message: message, onRetry: context.read<ProgressPhotosCubit>().loadPhotos);
        case ProgressPhotoPicked(:final pickedImage):
          showAddProgressPhotoSheet(context: context, pickedImage: pickedImage);
        case ProgressPhotoAdded():
          context.showToast(title: l10n.progressPhotosFeatureTitle, message: l10n.progressPhotosAddedMessage);
      }
    },
    builder: (context, cubit, state) {
      final l10n = context.l10n;
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.progressPhotosFeatureTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.compare_outlined),
              tooltip: l10n.progressPhotosCompareTitle,
              onPressed: state.canCompare
                  ? () => context.pushRoute(.progressPhotoCompare, extra: ProgressPhotoCompareExtra(photos: state.photos))
                  : null,
            ),
          ],
        ),
        floatingActionButton: state.photos.isEmpty
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _addPhoto(context),
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(l10n.progressPhotosAddAction),
              ),
        body: VTRefreshable(
          onRefresh: cubit.loadPhotos,
          isLoaded: state.isLoaded,
          skeleton: const ListSkeleton(headerHeight: 200),
          hasData: state.photos.isNotEmpty,
          emptyState: VTEmptyState(
            icon: Icons.photo_camera_outlined,
            title: l10n.progressPhotosEmptyTitle,
            message: l10n.progressPhotosEmptyMessage,
            actionLabel: l10n.progressPhotosAddAction,
            actionIcon: Icons.add_a_photo_outlined,
            onAction: () => _addPhoto(context),
          ),
          children: [
            const ProgressPhotoPrivacyNote(),
            const VTGap.l(),
            for (final section in state.months) ...[
              ProgressPhotoMonthSection(
                section: section,
                onPhotoTap: (photo) => showProgressPhotoViewer(context: context, photo: photo),
              ),
              const VTGap.l(),
            ],
          ],
        ),
      );
    },
  );
}
