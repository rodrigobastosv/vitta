import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/env/env.dart';

void loadTestEnv({String ios = 'appl_ios-key', String android = 'goog_android-key'}) {
  dotenv.loadFromString(
    envString: '''
SUPABASE_URL=https://example.supabase.co
SUPABASE_PUBLISHABLE_KEY=publishable
SENTRY_DSN=https://key@example.ingest.sentry.io/0
REVENUECAT_IOS_API_KEY=$ios
REVENUECAT_ANDROID_API_KEY=$android
''',
  );
  addTearDown(dotenv.clean);
}

void runAs(TargetPlatform platform) {
  debugDefaultTargetPlatformOverride = platform;
  addTearDown(() => debugDefaultTargetPlatformOverride = null);
}

void main() {
  test('an Android build reads the Play key, never the App Store one', () {
    loadTestEnv();
    runAs(TargetPlatform.android);

    expect(Env.revenueCatApiKey, 'goog_android-key');
  });

  test('an iOS build reads the App Store key', () {
    loadTestEnv();
    runAs(TargetPlatform.iOS);

    expect(Env.revenueCatApiKey, 'appl_ios-key');
  });

  test('a platform with no key configured reports empty rather than borrowing the other', () {
    loadTestEnv(android: '');
    runAs(TargetPlatform.android);

    expect(Env.revenueCatApiKey, isEmpty);
  });
}
