sealed class AuthPresentationEvent {}

class AuthShowLoading implements AuthPresentationEvent {}

class AuthHideLoading implements AuthPresentationEvent {}

class AuthSignedIn implements AuthPresentationEvent {}

class AuthActionFailed implements AuthPresentationEvent {
  const AuthActionFailed({required this.message});

  final String message;
}
