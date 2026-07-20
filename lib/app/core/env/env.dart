import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Env {
  static String get supabaseUrl => dotenv.get('SUPABASE_URL');

  static String get supabasePublishableKey => dotenv.get('SUPABASE_PUBLISHABLE_KEY');

  static String get sentryDsn => dotenv.get('SENTRY_DSN');

  /// Optional, unlike the others: a build without it still works, it just has no
  /// purchasable offer. Everything the app does apart from buying a subscription
  /// is unaffected, so a missing key degrades rather than crashing at launch.
  static String get revenueCatApiKey => dotenv.maybeGet('REVENUECAT_API_KEY') ?? '';
}
