import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/auth/auth_repository.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

class UpdateProfileUseCase {
  UpdateProfileUseCase({required this._authRepository});

  final AuthRepository _authRepository;

  Future<Result<VTError, User>> call({String? displayName, String? avatarId, String? avatarUrl}) =>
      _authRepository.updateProfile(displayName: displayName, avatarId: avatarId, avatarUrl: avatarUrl);
}
