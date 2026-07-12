import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/data/onboarding/onboarding_repository.dart';
import 'package:vitta/app/data/sleep/sleep_repository.dart';
import 'package:vitta/app/data/water/water_repository.dart';

class MockDietRepository extends Mock implements DietRepository {}

class MockWaterRepository extends Mock implements WaterRepository {}

class MockSleepRepository extends Mock implements SleepRepository {}

class MockOnboardingRepository extends Mock implements OnboardingRepository {}
