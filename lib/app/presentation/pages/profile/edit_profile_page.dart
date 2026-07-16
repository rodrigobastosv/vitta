import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';
import 'package:vitta/app/presentation/pages/auth/widgets/avatar_picker.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VTPage<AuthCubit, AuthState, AuthPresentationEvent>(
      onPresentation: (context, event) {
        switch (event) {
          case AuthShowLoading():
            context.showLoading();
          case AuthHideLoading():
            context.hideLoading();
          case AuthActionFailed(:final message):
            context.showErrorToast(message: message);
          case AuthProfileUpdated():
            context.showToast(title: l10n.profileUpdatedToast, message: l10n.profileUpdatedToastMessage);
            Navigator.of(context).pop();
          case AuthSignedIn():
            break;
        }
      },
      builder: (context, cubit, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.editProfileTitle)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(VTSpacing.m),
          child: _EditProfileForm(state: state, onSave: cubit.updateProfile),
        ),
      ),
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm({required this.state, required this.onSave});

  final AuthState state;
  final Future<void> Function({String? displayName}) onSave;

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final user = widget.state.user;
    _nameController = TextEditingController(text: user.displayNameOrEmpty);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthCubit>().seedAvatarFrom(user);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: .start,
      children: [
        AvatarPicker(state: widget.state),
        const VTGap.l(),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.authDisplayNameLabel),
        ),
        const VTGap.l(),
        VTPrimaryButton(
          label: l10n.editProfileSaveAction,
          onPressed: () => widget.onSave(displayName: _nameController.text.trim()),
        ),
      ],
    );
  }
}
