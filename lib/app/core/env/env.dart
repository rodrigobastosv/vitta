import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Env {
  static String get supabaseUrl => dotenv.get('SUPABASE_URL');

  static String get supabasePublishableKey => dotenv.get('SUPABASE_PUBLISHABLE_KEY');

  static String get sentryDsn => dotenv.get('SENTRY_DSN');

  /// The RevenueCat public SDK key **for the platform this build runs on**.
  ///
  /// A RevenueCat project holds one app per store, each with its own key, and the
  /// key is what identifies the app: configuring an Android build with the
  /// `appl_` key hands it the App Store app's offering, whose product ids Play
  /// has never heard of - which surfaces as `PRODUCT_NOT_FOUND` / "none of the
  /// products registered in the RevenueCat dashboard could be fetched from the
  /// Play Store", never as anything naming the key (issue #218).
  ///
  /// Optional, unlike the others: a build without it still works, it just has no
  /// purchasable offer. Everything the app does apart from buying a subscription
  /// is unaffected, so a missing key degrades rather than crashing at launch -
  /// and that now degrades per platform, so shipping iOS purchases while Android
  /// is still unconfigured is a legitimate state rather than a broken build.
  static String get revenueCatApiKey => switch (defaultTargetPlatform) {
    .android => _optional('REVENUECAT_ANDROID_API_KEY'),
    _ => _optional('REVENUECAT_IOS_API_KEY'),
  };

  /// The Firebase project the analytics events land in. Shared by both stores -
  /// one project holds an app per platform, and only the app-level identifiers
  /// below differ between them.
  static String get firebaseProjectId => _optional('FIREBASE_PROJECT_ID');

  static String get firebaseMessagingSenderId => _optional('FIREBASE_MESSAGING_SENDER_ID');

  /// The Firebase Web API key **for the platform this build runs on**, read off
  /// `google-services.json` / `GoogleService-Info.plist` rather than committed as
  /// either file. Public by design - it ships inside the binary and is scoped by
  /// the app id beside it, exactly like the RevenueCat key above.
  static String get firebaseApiKey => switch (defaultTargetPlatform) {
    .android => _optional('FIREBASE_ANDROID_API_KEY'),
    _ => _optional('FIREBASE_IOS_API_KEY'),
  };

  /// The per-store Firebase app id (`1:<sender>:android:<hash>`). Same split and
  /// same reason as `revenueCatApiKey`: it is what says which app you are, so
  /// handing an Android build the iOS id attributes its events to the wrong app.
  ///
  /// `FIREBASE_ANDROID_APP_ID` is deliberately the same value the Firebase App
  /// Distribution workflow already uses (docs/firebase-distribution-setup.md) -
  /// it is one app, distributed and measured.
  static String get firebaseAppId => switch (defaultTargetPlatform) {
    .android => _optional('FIREBASE_ANDROID_APP_ID'),
    _ => _optional('FIREBASE_IOS_APP_ID'),
  };

  static String _optional(String name) => dotenv.maybeGet(name) ?? '';
}
