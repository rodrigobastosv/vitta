import 'package:vitta/app/core/error/vt_error.dart';

// The Edge Function refused the call because the caller is not entitled to the
// feature (HTTP 402). It is a distinct type rather than a message so a cubit can
// open the paywall instead of showing a generic failure toast: the client-side
// lock can be stale - a subscription that lapsed while the app was open - and
// this is what the server says about it.
class PremiumRequiredError extends VTError {
  const PremiumRequiredError({super.cause}) : super(message: 'This feature requires a premium subscription');
}
