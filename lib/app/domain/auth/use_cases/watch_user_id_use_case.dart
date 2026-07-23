import 'package:vitta/app/data/auth/auth_repository.dart';

class WatchUserIdUseCase {
  WatchUserIdUseCase({required this._authRepository});

  final AuthRepository _authRepository;

  Stream<String?> call() => _authRepository.userIdChanges;
}
