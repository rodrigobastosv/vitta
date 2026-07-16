import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/auth/auth_repository.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

class SignUpUseCase {
  SignUpUseCase({required this._authRepository});

  final AuthRepository _authRepository;

  Future<Result<VTError, User>> call({
    required String email,
    required String password,
    String? displayName,
    String? avatarId,
    String? avatarUrl,
  }) => _authRepository.signUp(
    email: email,
    password: password,
    displayName: displayName,
    avatarId: avatarId,
    avatarUrl: avatarUrl,
  );
}
