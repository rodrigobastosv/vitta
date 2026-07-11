import 'package:get_it/get_it.dart';
import 'package:vitta/app/cubit/app_cubit.dart';

final G = GetIt.instance;

void setupDependencies() {
  G.registerLazySingleton(AppCubit.new);
}
