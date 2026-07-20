import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/premium/premium_repository.dart';
import 'package:vitta/app/domain/premium/entities/premium_status.dart';

class GetPremiumStatusUseCase {
  GetPremiumStatusUseCase({required this._premiumRepository});

  final PremiumRepository _premiumRepository;

  Future<Result<VTError, PremiumStatus>> call() => _premiumRepository.getStatus();
}
