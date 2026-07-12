import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/data/onboarding/onboarding_local_datasource.dart';
import 'package:vitta/app/data/settings/settings_local_datasource.dart';
import 'package:vitta/app/data/water/water_local_datasource.dart';

class MockSettingsLocalDataSource extends Mock implements SettingsLocalDataSource {}

class MockWaterLocalDataSource extends Mock implements WaterLocalDataSource {}

class MockOnboardingLocalDataSource extends Mock implements OnboardingLocalDataSource {}
