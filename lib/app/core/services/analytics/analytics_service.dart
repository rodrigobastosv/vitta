import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vitta/app/core/env/env.dart';
import 'package:vitta/app/core/services/analytics/analytics_parameters.dart';

/// Thin adapter over `firebase_analytics` (Google Analytics for Firebase) so
/// nothing above `core/services/` imports the SDK - the same boundary
/// `NotificationService`, `PurchaseService` and `HealthService` establish.
///
/// Configuration comes from `.env` rather than a committed
/// `google-services.json` / `GoogleService-Info.plist`, and is **optional**: a
/// build with no Firebase project configured simply reports nothing, exactly as
/// a build with no RevenueCat key simply has nothing to sell. Analytics must
/// never be the reason the app fails to launch.
///
/// Every report is **fire-and-forget and swallows its own failure** (`void`, not
/// `Future`). Nothing the app does depends on a report landing, so awaiting one
/// would only stall the action that produced it - and letting the future's error
/// escape would turn an unreachable analytics endpoint into a Sentry crash.
class AnalyticsService {
  FirebaseAnalytics? _analytics;

  /// Whether events go anywhere. False on a build with no Firebase project
  /// configured, and false until [init] has run.
  bool get isAvailable => _analytics != null;

  static bool get _isConfigured =>
      Env.firebaseApiKey.isNotEmpty && Env.firebaseAppId.isNotEmpty && Env.firebaseProjectId.isNotEmpty && Env.firebaseMessagingSenderId.isNotEmpty;

  Future<void> init() async {
    if (_analytics != null || !_isConfigured) {
      return;
    }
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: Env.firebaseApiKey,
        appId: Env.firebaseAppId,
        messagingSenderId: Env.firebaseMessagingSenderId,
        projectId: Env.firebaseProjectId,
      ),
    );
    _analytics = FirebaseAnalytics.instance;
  }

  void logEvent(String name, {Map<String, Object?> parameters = const {}}) {
    final sanitized = AnalyticsParameters.sanitize(parameters);
    _analytics?.logEvent(name: AnalyticsParameters.eventName(name), parameters: sanitized.isEmpty ? null : sanitized).ignore();
  }

  void logScreenView(String screenName) {
    _analytics?.logScreenView(screenName: AnalyticsParameters.screenName(screenName)).ignore();
  }

  /// Ties events to the Supabase `auth.uid()`, so a funnel can follow one person
  /// across their devices. Passing null unsets it, which is what a sign-out
  /// leaves behind - the next anonymous session must not inherit the identity.
  void setUserId(String? userId) {
    _analytics?.setUserId(id: userId).ignore();
  }
}
