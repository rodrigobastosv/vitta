import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/purchases/purchase_service.dart';
import 'package:vitta/app/data/auth/auth_repository.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

class SignOutUseCase {
  SignOutUseCase({required this._authRepository, required this._purchaseService});

  final AuthRepository _authRepository;
  final PurchaseService _purchaseService;

  Future<Result<VTError, User>> call() async {
    await _purchaseService.logOut();
    final signedOutResult = await _authRepository.signOut();
    return signedOutResult.when((error) => Future.value(Failure(error)), (_) => _authRepository.signInAnonymously());
  }
}
