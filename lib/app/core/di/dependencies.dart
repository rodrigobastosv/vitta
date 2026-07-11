import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitta/app/core/http/vt_http_client.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/data/diet/datasources/open_food_facts_datasource.dart';
import 'package:vitta/app/data/diet/datasources/supabase_diet_datasource.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';
import 'package:vitta/app/domain/diet/use_cases/delete_food_log_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/get_daily_macros_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/log_food_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/search_foods_use_case.dart';
import 'package:vitta/app/presentation/pages/diet/diet_cubit.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';

final G = GetIt.instance;

void setupDependencies() {
  G.registerLazySingleton(AppCubit.new);

  G.registerLazySingleton(() => Supabase.instance.client);
  G.registerLazySingleton(() => VTHttpClient(baseUrl: 'https://world.openfoodfacts.org'));
  G.registerLazySingleton(() => OpenFoodFactsDataSource(httpClient: G()));
  G.registerLazySingleton(() => SupabaseDietDataSource(supabaseClient: G()));
  G.registerLazySingleton(() => DietRepository(openFoodFactsDataSource: G(), supabaseDietDataSource: G()));

  G.registerFactory(() => SearchFoodsUseCase(dietRepository: G()));
  G.registerFactory(() => LogFoodUseCase(dietRepository: G()));
  G.registerFactory(() => GetDailyMacrosUseCase(dietRepository: G()));
  G.registerFactory(() => DeleteFoodLogUseCase(dietRepository: G()));

  G.registerFactory(() => DietCubit(getDailyMacrosUseCase: G(), deleteFoodLogUseCase: G()));
  G.registerFactory(() => FoodSearchCubit(searchFoodsUseCase: G(), logFoodUseCase: G()));
}
