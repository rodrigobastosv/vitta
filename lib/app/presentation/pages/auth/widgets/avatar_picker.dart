import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_source.dart';
import 'package:vitta/app/design_system/components/general/vt_avatar_picker_sheet.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/components/general/vt_profile_avatar.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/design_system/vt_bottom_sheet.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';

class AvatarPicker extends StatelessWidget {
  const AvatarPicker({required this.state, super.key});

  final AuthState state;

  String? get _persistedAvatarId => switch (state.user) {
    AuthenticatedUser(:final avatarId) => avatarId,
    _ => null,
  };

  String? get _persistedUrl => switch (state.user) {
    AuthenticatedUser(:final avatarUrl) => avatarUrl,
    _ => null,
  };

  String? get _initial => switch (state.user) {
    final AuthenticatedUser user => user.initial,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AuthCubit>();
    return Center(
      child: Column(
        mainAxisSize: .min,
        children: [
          Text(l10n.authAvatarLabel, style: VTTextStyles.caption(context)),
          const VTGap.s(),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _openMenu(context, cubit),
            child: Stack(
              alignment: .bottomRight,
              children: [
                VTProfileAvatar(
                  avatarUrl: state.hasDraftPhoto || state.draftAvatarId != null ? null : _persistedUrl,
                  avatarId: state.draftAvatarId ?? (state.hasDraftPhoto ? null : _persistedAvatarId),
                  previewBytes: state.draftAvatarBytes,
                  initial: _initial,
                  size: 88,
                ),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: context.colorScheme.primary,
                  child: Icon(Icons.edit, size: 15, color: context.colorScheme.onPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMenu(BuildContext context, AuthCubit cubit) async {
    final l10n = context.l10n;
    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      routeSettings: VTBottomSheet.avatarAction.settings,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: .min,
          children: [
            ListTile(
              leading: const Icon(Icons.face_outlined),
              title: Text(l10n.authPickAvatarAction),
              onTap: () => Navigator.of(sheetContext).pop(_AvatarAction.preset),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.takePhotoAction),
              onTap: () => Navigator.of(sheetContext).pop(_AvatarAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.chooseFromGalleryAction),
              onTap: () => Navigator.of(sheetContext).pop(_AvatarAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(l10n.authRemoveAvatarAction),
              onTap: () => Navigator.of(sheetContext).pop(_AvatarAction.remove),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) {
      return;
    }
    switch (action) {
      case _AvatarAction.preset:
        final avatarId = await showAvatarPickerSheet(context: context);
        if (avatarId != null) {
          cubit.setAvatarPreset(avatarId);
        }
      case _AvatarAction.camera:
        await cubit.pickAvatarPhoto(ImagePickerSource.camera);
      case _AvatarAction.gallery:
        await cubit.pickAvatarPhoto(ImagePickerSource.gallery);
      case _AvatarAction.remove:
        cubit.clearAvatar();
    }
  }
}

enum _AvatarAction { preset, camera, gallery, remove }
