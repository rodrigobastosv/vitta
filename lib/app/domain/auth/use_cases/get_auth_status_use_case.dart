import 'package:vitta/app/data/auth/auth_repository.dart';
import 'package:vitta/app/domain/auth/entities/auth_status.dart';

class GetAuthStatusUseCase {
  GetAuthStatusUseCase({required this._authRepository});

  final AuthRepository _authRepository;

  AuthStatus call() => _authRepository.status;
}
