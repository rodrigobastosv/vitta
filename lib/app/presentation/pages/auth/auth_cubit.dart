import 'package:vitta/app/domain/auth/use_cases/get_auth_status_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_in_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_out_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_up_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';

class AuthCubit extends PresentationCubit<AuthState, AuthPresentationEvent> {
  AuthCubit({
    required GetAuthStatusUseCase getAuthStatusUseCase,
    required this._signUpUseCase,
    required this._signInUseCase,
    required this._signOutUseCase,
  }) : _getAuthStatusUseCase = getAuthStatusUseCase,
       super(AuthLoaded(status: getAuthStatusUseCase()));

  final GetAuthStatusUseCase _getAuthStatusUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;

  void refreshStatus() => emit(AuthLoaded(status: _getAuthStatusUseCase()));

  Future<void> signUp({required String email, required String password}) async {
    emitPresentation(AuthShowLoading());
    final statusResult = await _signUpUseCase(email: email, password: password);
    emitPresentation(AuthHideLoading());
    statusResult.when((error) => emitPresentation(AuthActionFailed(message: error.message)), (value) {
      emit(AuthLoaded(status: value));
      emitPresentation(AuthSignedIn());
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    emitPresentation(AuthShowLoading());
    final statusResult = await _signInUseCase(email: email, password: password);
    emitPresentation(AuthHideLoading());
    statusResult.when((error) => emitPresentation(AuthActionFailed(message: error.message)), (value) {
      emit(AuthLoaded(status: value));
      emitPresentation(AuthSignedIn());
    });
  }

  Future<void> signOut() async {
    emitPresentation(AuthShowLoading());
    final statusResult = await _signOutUseCase();
    emitPresentation(AuthHideLoading());
    statusResult.when((error) => emitPresentation(AuthActionFailed(message: error.message)), (value) => emit(AuthLoaded(status: value)));
  }
}
