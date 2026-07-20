import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/domain/premium/entities/premium_status.dart';
import 'package:vitta/app/domain/premium/use_cases/get_premium_status_use_case.dart';
import 'package:vitta/app/presentation/pages/premium/premium_state.dart';

// A plain Cubit provided once at the root, like AppCubit, rather than a
// PresentationCubit resolved per page: the entitlement gates affordances on
// several unrelated screens, and a factory would re-read it over the network on
// every page build and make the locks flicker in.
class PremiumCubit extends Cubit<PremiumState> {
  PremiumCubit({required this._getPremiumStatusUseCase}) : super(const PremiumState.free()) {
    refresh();
  }

  final GetPremiumStatusUseCase _getPremiumStatusUseCase;

  // A failed read leaves the user free, which is the safe direction: it locks a
  // paid feature rather than giving it away, and the Edge Function is the real
  // gate anyway. There is deliberately no error toast - a startup complaint
  // about a subscription most users do not have would be pure noise.
  Future<void> refresh() async {
    final statusResult = await _getPremiumStatusUseCase();
    final status = statusResult.when((_) => const PremiumStatus.free(), (status) => status);
    emit(state.copyWith(status: status));
  }
}
