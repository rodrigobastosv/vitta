import 'package:vitta/app/domain/auth/use_cases/get_user_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_in_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_out_use_case.dart';
import 'package:vitta/app/domain/auth/use_cases/sign_up_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';

class AuthCubit extends PresentationCubit<AuthState, AuthPresentationEvent> {
  AuthCubit({
    required GetUserUseCase getUserUseCase,
    required this._signUpUseCase,
    required this._signInUseCase,
    required this._signOutUseCase,
  }) : _getUserUseCase = getUserUseCase,
       super(AuthState(user: getUserUseCase()));

  final GetUserUseCase _getUserUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;

  void refreshUser() => emit(state.copyWith(user: _getUserUseCase()));

  void setSignUpMode({required bool isSignUp}) => emit(state.copyWith(isSignUpMode: isSignUp));

  Future<void> submit({required String email, required String password}) async {
    emitPresentation(AuthShowLoading());
    final statusResult = state.isSignUpMode
        ? await _signUpUseCase(email: email, password: password)
        : await _signInUseCase(email: email, password: password);
    emitPresentation(AuthHideLoading());
    statusResult.when((error) => emitPresentation(AuthActionFailed(message: error.message)), (value) {
      emit(state.copyWith(user: value));
      emitPresentation(AuthSignedIn());
    });
  }

  Future<void> signOut() async {
    emitPresentation(AuthShowLoading());
    final statusResult = await _signOutUseCase();
    emitPresentation(AuthHideLoading());
    statusResult.when((error) => emitPresentation(AuthActionFailed(message: error.message)), (user) => emit(state.copyWith(user: user)));
  }
}
