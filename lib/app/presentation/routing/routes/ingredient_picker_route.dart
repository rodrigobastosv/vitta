import 'package:go_router/go_router.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/presentation/pages/ingredient_picker/ingredient_picker_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class IngredientPickerRoute extends VTRoute {
  @override
  AppRoute get route => .ingredientPicker;

  @override
  GoRouterWidgetBuilder get builder => (context, state) => IngredientPickerPage(unitSystem: state.extra! as UnitSystem);
}
