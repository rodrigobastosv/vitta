import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/auth/auth_repository.dart';
import 'package:vitta/app/domain/auth/entities/auth_status.dart';

class SignInUseCase {
  SignInUseCase({required this._authRepository});

  final AuthRepository _authRepository;

  Future<Result<VTError, AuthStatus>> call({required String email, required String password}) =>
      _authRepository.signIn(email: email, password: password);
}
