import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/auth/auth_repository.dart';
import 'package:vitta/app/domain/auth/entities/auth_status.dart';

class SignOutUseCase {
  SignOutUseCase({required this._authRepository});

  final AuthRepository _authRepository;

  Future<Result<VTError, AuthStatus>> call() async {
    final signedOutResult = await _authRepository.signOut();
    return signedOutResult.when((error) => Future.value(Failure(error)), (_) => _authRepository.signInAnonymously());
  }
}
