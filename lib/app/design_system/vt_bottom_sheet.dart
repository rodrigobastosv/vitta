import 'package:flutter/widgets.dart';

// The app's modal bottom sheets, each paired with the name it logs under — the
// way AppRoute pairs a case with its path. Sheets are pushed anonymously, so
// without this the navigation log (LoggingNavigatorObserver) can only record the
// route kind ("bottomSheet"); passing `sheet.settings` tells it which one opened.
// Lives in the design system so the VT* sheets here can name themselves without a
// dependency on presentation/routing.
enum VTBottomSheet {
  logFood('logFoodSheet'),
  logRecipe('logRecipeSheet'),
  editFoodLog('editFoodLogSheet'),
  ingredientQuantity('ingredientQuantitySheet'),
  dietCalendar('dietCalendarSheet'),
  logSleep('logSleepSheet'),
  logBodyWeight('logBodyWeightSheet'),
  reminderForm('reminderFormSheet'),
  logSet('logSetSheet'),
  restLength('restLengthSheet'),
  avatarPicker('avatarPickerSheet'),
  avatarAction('avatarActionSheet'),
  imageSource('imageSourceSheet'),
  addProgressPhoto('addProgressPhotoSheet'),
  progressPhotoPicker('progressPhotoPickerSheet');

  const VTBottomSheet(this.routeName);

  final String routeName;

  RouteSettings get settings => RouteSettings(name: routeName);
}
