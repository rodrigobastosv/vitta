import 'package:vitta/app/data/auth/auth_repository.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

class GetUserUseCase {
  GetUserUseCase({required this._authRepository});

  final AuthRepository _authRepository;

  User call() => _authRepository.status;
}
