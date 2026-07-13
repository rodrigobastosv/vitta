import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/data/onboarding/onboarding_local_datasource.dart';
import 'package:vitta/app/data/water/datasources/local/water_local_datasource.dart';

class MockWaterLocalDataSource extends Mock implements WaterLocalDataSource {}

class MockOnboardingLocalDataSource extends Mock implements OnboardingLocalDataSource {}
