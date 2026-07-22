import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/core/env/env.dart';

void loadTestEnv({
  String ios = 'appl_ios-key',
  String android = 'goog_android-key',
  String firebaseIosApiKey = 'ios-api-key',
  String firebaseAndroidApiKey = 'android-api-key',
}) {
  dotenv.loadFromString(
    envString:
        '''
SUPABASE_URL=https://example.supabase.co
SUPABASE_PUBLISHABLE_KEY=publishable
SENTRY_DSN=https://key@example.ingest.sentry.io/0
REVENUECAT_IOS_API_KEY=$ios
REVENUECAT_ANDROID_API_KEY=$android
FIREBASE_PROJECT_ID=vitta-test
FIREBASE_MESSAGING_SENDER_ID=1234567890
FIREBASE_IOS_API_KEY=$firebaseIosApiKey
FIREBASE_IOS_APP_ID=1:1234567890:ios:abc
FIREBASE_ANDROID_API_KEY=$firebaseAndroidApiKey
FIREBASE_ANDROID_APP_ID=1:1234567890:android:abc
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

  test('an Android build reads the Android Firebase app, never the iOS one', () {
    loadTestEnv();
    runAs(TargetPlatform.android);

    expect(Env.firebaseApiKey, 'android-api-key');
    expect(Env.firebaseAppId, '1:1234567890:android:abc');
  });

  test('an iOS build reads the iOS Firebase app', () {
    loadTestEnv();
    runAs(TargetPlatform.iOS);

    expect(Env.firebaseApiKey, 'ios-api-key');
    expect(Env.firebaseAppId, '1:1234567890:ios:abc');
  });

  test('the Firebase project is shared by both stores', () {
    loadTestEnv();
    runAs(TargetPlatform.android);

    expect(Env.firebaseProjectId, 'vitta-test');
    expect(Env.firebaseMessagingSenderId, '1234567890');
  });

  test('an unconfigured Firebase platform reports empty rather than borrowing the other store', () {
    loadTestEnv(firebaseAndroidApiKey: '');
    runAs(TargetPlatform.android);

    expect(Env.firebaseApiKey, isEmpty);
  });
}
