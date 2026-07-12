import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/data/onboarding/onboarding_local_datasource.dart';

import '../../../fixtures/local_storage_fixture.dart';

void main() {
  test('hasSeenOnboarding defaults to false when nothing was saved', () async {
    final dataSource = OnboardingLocalDataSource(localStorageService: await buildTestLocalStorageService());

    expect(dataSource.hasSeenOnboarding(), isFalse);
  });

  test('markOnboardingSeen persists and hasSeenOnboarding reads it back', () async {
    final dataSource = OnboardingLocalDataSource(localStorageService: await buildTestLocalStorageService());

    await dataSource.markOnboardingSeen();

    expect(dataSource.hasSeenOnboarding(), isTrue);
  });
}
