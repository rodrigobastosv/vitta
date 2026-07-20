import 'package:supabase_flutter/supabase_flutter.dart';

const _httpPaymentRequired = 402;

// The premium gate lives in the Edge Function, not the client (see
// docs/premium-setup.md), and 402 is how it refuses an unentitled caller.
extension SupabaseFunctionExceptionExt on FunctionException {
  bool get isPremiumRequired => status == _httpPaymentRequired;
}
