import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/purchases/purchase_service.dart';
import 'package:vitta/app/data/auth/auth_repository.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';

class DeleteAccountUseCase {
  DeleteAccountUseCase({required this._authRepository, required this._purchaseService});

  final AuthRepository _authRepository;
  final PurchaseService _purchaseService;

  Future<Result<VTError, User>> call() async {
    final deletedResult = await _authRepository.deleteAccount();
    return deletedResult.when((error) => Future.value(Failure(error)), (_) async {
      await _purchaseService.logOut();
      await _authRepository.signOut();
      return _authRepository.signInAnonymously();
    });
  }
}
