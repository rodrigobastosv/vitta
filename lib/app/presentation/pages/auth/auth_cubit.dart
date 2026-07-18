import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_service.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_source.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/domain/auth/use_cases/delete_account_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/get_user_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_in_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_out_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_up_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/update_profile_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/upload_avatar_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';

class AuthCubit extends PresentationCubit<AuthState, AuthPresentationEvent> {
  AuthCubit({
    required GetUserUseCase getUserUseCase,
    required this._signUpUseCase,
    required this._signInUseCase,
    required this._signOutUseCase,
    required this._updateProfileUseCase,
    required this._uploadAvatarUseCase,
    required this._deleteAccountUseCase,
    required this._imagePickerService,
  }) : _getUserUseCase = getUserUseCase,
       super(AuthState(user: getUserUseCase()));

  final GetUserUseCase _getUserUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final ImagePickerService _imagePickerService;

  static const double _avatarMaxWidth = 512;

  void refreshUser() => emit(state.copyWith(user: _getUserUseCase()));

  void seedAvatarFrom(User user) {
    if (user case AuthenticatedUser(:final avatarId?)) {
      emit(state.withPresetAvatar(avatarId));
    } else {
      emit(state.withoutAvatar());
    }
  }

  void setAvatarPreset(String id) => emit(state.withPresetAvatar(id));

  void clearAvatar() => emit(state.withoutAvatar());

  Future<void> pickAvatarPhoto(ImagePickerSource source) async {
    final pickedImage = await _imagePickerService.pickImage(source: source, maxWidth: _avatarMaxWidth);
    if (pickedImage == null) {
      return;
    }
    emit(state.withPhotoAvatar(bytes: pickedImage.bytes, extension: pickedImage.fileExtension));
  }

  Future<void> signIn({required String email, required String password}) async {
    emitPresentation(AuthShowLoading());
    final statusResult = await _signInUseCase(email: email, password: password);
    emitPresentation(AuthHideLoading());
    _onAuthResult(statusResult, action: 'sign_in');
  }

  Future<void> signUp({required String email, required String password, String? displayName}) async {
    emitPresentation(AuthShowLoading());
    final avatarResult = await _resolveDraftAvatar();
    final avatarError = avatarResult.when((error) => error, (_) => null);
    if (avatarError != null) {
      emitPresentation(AuthHideLoading());
      emitPresentation(AuthActionFailed(message: avatarError.message));
      return;
    }
    final avatar = avatarResult.when((_) => const _ResolvedAvatar(), (value) => value);
    final statusResult = await _signUpUseCase(
      email: email,
      password: password,
      displayName: _trimToNull(displayName),
      avatarId: avatar.id,
      avatarUrl: avatar.url,
    );
    emitPresentation(AuthHideLoading());
    _onAuthResult(statusResult, action: 'sign_up');
  }

  void _onAuthResult(Result<VTError, User> statusResult, {required String action}) {
    statusResult.when((error) => emitPresentation(AuthActionFailed(message: error.message)), (value) {
      Log.action(action);
      emit(state.copyWith(user: value));
      emitPresentation(AuthSignedIn());
    });
  }

  Future<void> updateProfile({String? displayName}) async {
    emitPresentation(AuthShowLoading());
    final avatarResult = await _resolveDraftAvatar();
    final avatarError = avatarResult.when((error) => error, (_) => null);
    if (avatarError != null) {
      emitPresentation(AuthHideLoading());
      emitPresentation(AuthActionFailed(message: avatarError.message));
      return;
    }
    final avatar = avatarResult.when((_) => const _ResolvedAvatar(), (value) => value);
    final statusResult = await _updateProfileUseCase(displayName: _trimToNull(displayName), avatarId: avatar.id, avatarUrl: avatar.url);
    emitPresentation(AuthHideLoading());
    statusResult.when((error) => emitPresentation(AuthActionFailed(message: error.message)), (value) {
      Log.action('profile_updated');
      emit(state.copyWith(user: value));
      emitPresentation(AuthProfileUpdated());
    });
  }

  Future<Result<VTError, _ResolvedAvatar>> _resolveDraftAvatar() async {
    final bytes = state.draftAvatarBytes;
    if (bytes != null) {
      final uploadResult = await _uploadAvatarUseCase(bytes: bytes, fileExtension: state.draftAvatarExtension);
      return uploadResult.when(Failure.new, (url) => Success(_ResolvedAvatar(url: url)));
    }
    return Success(_ResolvedAvatar(id: state.draftAvatarId));
  }

  String? _trimToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  Future<void> signOut() async {
    emitPresentation(AuthShowLoading());
    final statusResult = await _signOutUseCase();
    emitPresentation(AuthHideLoading());
    statusResult.when((error) => emitPresentation(AuthActionFailed(message: error.message)), (user) {
      Log.action('sign_out');
      emit(state.copyWith(user: user));
    });
  }

  Future<void> deleteAccount() async {
    emitPresentation(AuthShowLoading());
    final statusResult = await _deleteAccountUseCase();
    emitPresentation(AuthHideLoading());
    statusResult.when((error) => emitPresentation(AuthActionFailed(message: error.message)), (user) {
      Log.action('account_deleted');
      emit(state.copyWith(user: user));
      emitPresentation(AuthAccountDeleted());
    });
  }
}

class _ResolvedAvatar {
  const _ResolvedAvatar({this.id, this.url});

  final String? id;
  final String? url;
}
