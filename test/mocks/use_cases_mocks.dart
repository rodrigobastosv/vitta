import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/log_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/search_foods_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/delete_water_log_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/get_daily_water_use_case.dart';
import 'package:vitta/app/domain/water/use_cases/log_water_use_case.dart';

class MockSearchFoodsUseCase extends Mock implements SearchFoodsUseCase {}

class MockLogFoodUseCase extends Mock implements LogFoodUseCase {}

class MockGetDailyMacrosUseCase extends Mock implements GetDailyMacrosUseCase {}

class MockDeleteFoodLogUseCase extends Mock implements DeleteFoodLogUseCase {}

class MockLogWaterUseCase extends Mock implements LogWaterUseCase {}

class MockGetDailyWaterUseCase extends Mock implements GetDailyWaterUseCase {}

class MockDeleteWaterLogUseCase extends Mock implements DeleteWaterLogUseCase {}
