import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_log.dart';
import 'package:vitta/app/domain/diet/entities/food_log_entry.dart';

import 'food_factory.dart';
import 'food_log_factory.dart';

FoodLogEntry buildFoodLogEntry({FoodLog? log, Food? food}) => FoodLogEntry(log: log ?? buildFoodLog(), food: food ?? buildFood());
