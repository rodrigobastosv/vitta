// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vitta';

  @override
  String get homeTagline => 'Your companion for diet and training.';

  @override
  String get dietFeatureTitle => 'Diet';

  @override
  String get dietFeatureSubtitle => 'Track meals and reach your nutrition goals';

  @override
  String get workoutFeatureTitle => 'Workout';

  @override
  String get workoutFeatureSubtitle => 'Plan and log your training sessions';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get themeSystemDefault => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsUnitSystemLabel => 'Unit system';

  @override
  String get unitSystemMetric => 'Metric (g/kg)';

  @override
  String get unitSystemImperial => 'Imperial (oz/lb)';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get dietComingSoonMessage => 'Diet tracking is on its way.';

  @override
  String get workoutComingSoonMessage => 'Workout tracking is on its way.';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String progressLabel(String consumed, String goal, String unit) {
    return '$consumed / $goal $unit';
  }

  @override
  String dietCaloriesLabel(int calories) {
    return '$calories kcal today';
  }

  @override
  String dietCaloriesOfGoal(int goal) {
    return 'of $goal kcal';
  }

  @override
  String dietCaloriesLeft(int calories) {
    return '$calories kcal left';
  }

  @override
  String dietCaloriesOver(int calories) {
    return '$calories kcal over';
  }

  @override
  String get dietAddFood => 'Add food';

  @override
  String get dietProteinLabel => 'Protein';

  @override
  String get dietCarbsLabel => 'Carbs';

  @override
  String get dietFatLabel => 'Fat';

  @override
  String dietLogSubtitle(int grams, int calories) {
    return '$grams g - $calories kcal';
  }

  @override
  String get dietDeleteLogTooltip => 'Remove';

  @override
  String get dietToday => 'Today';

  @override
  String get dietYesterday => 'Yesterday';

  @override
  String get dietPreviousDayTooltip => 'Previous day';

  @override
  String get dietNextDayTooltip => 'Next day';

  @override
  String get dietEmptyTitle => 'Nothing logged yet';

  @override
  String get dietNotTodayEmptyTitle => 'Nothing logged on that day';

  @override
  String get dietEmptyMessage => 'Tap the + button to add the first food of the day.';

  @override
  String get dietNotTodayEmptyMessage => 'Tap + to log food for this day.';

  @override
  String get dietInvalidQuantity => 'Enter a quantity greater than zero.';

  @override
  String dietQuantityLabel(String unit) {
    return 'Quantity ($unit)';
  }

  @override
  String get dietLogFoodAction => 'Add to day';

  @override
  String dietFoodLoggedToast(String meal) {
    return 'Added to $meal';
  }

  @override
  String get dietInvalidCustomFood => 'Fill in the name and all macros with valid numbers.';

  @override
  String get dietCustomFoodTitle => 'Add a food';

  @override
  String get dietCustomFoodSubtitle => 'It joins the shared catalog for everyone.';

  @override
  String get dietFoodNameLabel => 'Name';

  @override
  String get dietFoodNameHint => 'Greek yogurt, rolled oats, ...';

  @override
  String get dietBrandLabel => 'Brand (optional)';

  @override
  String get dietBrandHint => 'Who makes it';

  @override
  String get addPhotoAction => 'Add a photo';

  @override
  String get changePhotoAction => 'Change photo';

  @override
  String get dietScanLabelHint => 'Snap the nutrition table and we fill in the values for you.';

  @override
  String get dietEnergyLabel => 'Calories';

  @override
  String get dietKcalUnit => 'kcal';

  @override
  String get dietGramsUnit => 'g';

  @override
  String get dietEnergySplitTitle => 'Energy split';

  @override
  String dietMacroPercent(int percent) {
    return '$percent%';
  }

  @override
  String get dietFiberLabel => 'Fiber';

  @override
  String get dietMicronutrientsTitle => 'Vitamins & minerals';

  @override
  String dietMicronutrientAmount(String amount, String unit) {
    return '$amount $unit';
  }

  @override
  String get nutrientVitaminA => 'Vitamin A';

  @override
  String get nutrientVitaminC => 'Vitamin C';

  @override
  String get nutrientVitaminD => 'Vitamin D';

  @override
  String get nutrientVitaminE => 'Vitamin E';

  @override
  String get nutrientVitaminK => 'Vitamin K';

  @override
  String get nutrientVitaminB1 => 'Vitamin B1';

  @override
  String get nutrientVitaminB2 => 'Vitamin B2';

  @override
  String get nutrientVitaminB3 => 'Vitamin B3';

  @override
  String get nutrientVitaminB6 => 'Vitamin B6';

  @override
  String get nutrientFolate => 'Folate';

  @override
  String get nutrientVitaminB12 => 'Vitamin B12';

  @override
  String get nutrientCalcium => 'Calcium';

  @override
  String get nutrientIron => 'Iron';

  @override
  String get nutrientMagnesium => 'Magnesium';

  @override
  String get nutrientPotassium => 'Potassium';

  @override
  String get nutrientSodium => 'Sodium';

  @override
  String get nutrientZinc => 'Zinc';

  @override
  String get takePhotoAction => 'Take photo';

  @override
  String get chooseFromGalleryAction => 'Choose from gallery';

  @override
  String get dietContinueAction => 'Continue';

  @override
  String get dietScanLabelAction => 'Scan nutrition label';

  @override
  String get dietNutritionScanNoData => 'Couldn\'t read the nutrition label. Enter the values manually.';

  @override
  String dietCaloriesPer100g(int calories) {
    return '$calories kcal / 100g';
  }

  @override
  String get dietFoodSearchTitle => 'Search foods';

  @override
  String get dietFavoritesTitle => 'Favorites';

  @override
  String get dietSearchTabLabel => 'Search';

  @override
  String get dietFavoritesEmptyTitle => 'No favorites yet';

  @override
  String get dietFavoritesEmptyMessage => 'Tap the heart on any food to keep it here, one tap away.';

  @override
  String get dietFavoriteFoodTooltip => 'Add to favorites';

  @override
  String get dietUnfavoriteFoodTooltip => 'Remove from favorites';

  @override
  String get dietSearchFieldLabel => 'Search Open Food Facts';

  @override
  String get dietSearchPrompt => 'Search for a food to log it.';

  @override
  String get dietSearchNoResults => 'No results. Try another search or add it manually.';

  @override
  String get dietNutritionPer100gTitle => 'Nutrition per 100g';

  @override
  String dietMacroGrams(String grams) {
    return '$grams g';
  }

  @override
  String get dietHistoryTitle => 'History';

  @override
  String get dietHistoryTrendsTitle => 'Trends';

  @override
  String dietWeekAverageShort(int calories) {
    return '$calories';
  }

  @override
  String dietWeekAverageTooltip(int calories, int days) {
    return 'Weekly average: $calories kcal over $days logged days';
  }

  @override
  String get dietWeekColumnLabel => 'Avg';

  @override
  String dietTrendRangeDays(int days) {
    return '${days}d';
  }

  @override
  String get dietCaloriesTrendTitle => 'Calories';

  @override
  String get dietMacrosTrendTitle => 'Macros';

  @override
  String dietTrendAverageLabel(int calories) {
    return '$calories kcal/day average';
  }

  @override
  String dietTrendLoggedDays(int days, int total) {
    return '$days of $total days logged';
  }

  @override
  String get dietTrendEmptyMessage => 'Nothing logged in this period yet.';

  @override
  String get dietHistoryCalendarEmptyMessage => 'Nothing logged this month.';

  @override
  String get dietDayDetailsEmptyMessage => 'Nothing was logged on this day.';

  @override
  String get dietGoalLineLabel => 'Goal';

  @override
  String get dietCopyMealsTitle => 'Copy meals';

  @override
  String get dietCopyMealsPrompt => 'Pick the day you want to copy meals from.';

  @override
  String get dietCopyMealsNoSourceTitle => 'No day picked';

  @override
  String get dietCopyMealsNoSourceMessage => 'Tap a day with food logged to choose which meals to copy.';

  @override
  String get dietCopyMealsSelectionTitle => 'Meals to copy';

  @override
  String get dietCopyMealsAction => 'Copy meals';

  @override
  String dietCopyMealFoodCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count foods', one: '1 food');
    return '$_temp0';
  }

  @override
  String get dietMealsCopiedToastTitle => 'Meals copied';

  @override
  String dietMealsCopiedToastMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals added to your day',
      one: '1 meal added to your day',
    );
    return '$_temp0';
  }

  @override
  String get dietMealSplitTitle => 'Calories by meal';

  @override
  String dietMealSplitAverage(int calories) {
    return '$calories kcal/day';
  }

  @override
  String get dietRecipesTitle => 'My recipes';

  @override
  String get dietRecipesEmptyTitle => 'No recipes yet';

  @override
  String get dietRecipesEmptyMessage => 'Tap + to combine foods into a recipe you can log in one go.';

  @override
  String get dietEditRecipeTitle => 'Edit recipe';

  @override
  String get dietCreateRecipeTitle => 'New recipe';

  @override
  String get dietRecipeNameLabel => 'Recipe name';

  @override
  String get dietRecipeNameHint => 'Sunday lasagna, protein shake, ...';

  @override
  String get dietRecipeIngredientsTitle => 'Ingredients';

  @override
  String get dietRecipeAddIngredientAction => 'Add ingredient';

  @override
  String get dietRecipeNoIngredientsMessage => 'Add the foods this recipe is made of.';

  @override
  String get dietRecipeIncomplete => 'Give the recipe a name and at least one ingredient.';

  @override
  String get dietRecipeTotalsTitle => 'Recipe totals';

  @override
  String dietRecipeTotalGrams(int grams) {
    return '$grams g total';
  }

  @override
  String get dietRecipeSaveAction => 'Save recipe';

  @override
  String get dietRecipeSavedToast => 'Saved as a food you can log';

  @override
  String get dietRecipeDeleteTooltip => 'Remove';

  @override
  String dietRecipeIngredientCount(int count, int grams) {
    return '$count ingredients - $grams g';
  }

  @override
  String get dietPickIngredientTitle => 'Pick a food';

  @override
  String get dietRecipeSubtitle => 'Recipes are yours only and never show up in anyone else\'s search.';

  @override
  String get dietRecipeLogHint => 'Search it by name in Add food to log it on any day.';

  @override
  String get mealTypeBreakfast => 'Breakfast';

  @override
  String get mealTypeLunch => 'Lunch';

  @override
  String get mealTypeDinner => 'Dinner';

  @override
  String get mealTypeSnack => 'Snack';

  @override
  String dietMealCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String dietMealMacros(int protein, int carbs, int fat, int fiber) {
    return 'P ${protein}g · C ${carbs}g · F ${fat}g · Fiber ${fiber}g';
  }

  @override
  String dietAddToMeal(String meal) {
    return 'Add to $meal';
  }

  @override
  String get cancelAction => 'Cancel';

  @override
  String get saveAction => 'Save';

  @override
  String get waterFeatureTitle => 'Water';

  @override
  String get waterFeatureSubtitle => 'Track how much water you drink each day';

  @override
  String get waterDeleteLogTooltip => 'Remove';

  @override
  String get waterEmptyTitle => 'Nothing logged yet';

  @override
  String get waterEmptyMessage => 'Tap the + button to log the first glass of water.';

  @override
  String get waterQuickAddTitle => 'Add water';

  @override
  String waterCustomAmountLabel(String unit) {
    return 'Custom amount ($unit)';
  }

  @override
  String get waterLogAction => 'Add';

  @override
  String get waterInvalidAmount => 'Enter an amount greater than zero.';

  @override
  String get waterGoalDialogTitle => 'Daily goal';

  @override
  String waterGoalLabel(String unit) {
    return 'Daily goal ($unit)';
  }

  @override
  String get sleepFeatureTitle => 'Sleep';

  @override
  String get sleepFeatureSubtitle => 'Track your sleep patterns';

  @override
  String get sleepEmptyTitle => 'Nothing logged yet';

  @override
  String get sleepEmptyMessage => 'Tap the + button to log your first night of sleep.';

  @override
  String get sleepDeleteLogTooltip => 'Remove';

  @override
  String get sleepLogSheetTitle => 'Log sleep';

  @override
  String get sleepBedTimeLabel => 'Bed time';

  @override
  String get sleepWakeTimeLabel => 'Wake time';

  @override
  String get sleepQualityLabel => 'Quality (optional)';

  @override
  String get sleepInvalidRange => 'Wake time must be after bed time.';

  @override
  String get sleepLogAction => 'Log sleep';

  @override
  String sleepDurationLabel(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get onboardingWelcomeTitle => 'Welcome to Vitta';

  @override
  String get onboardingWelcomeMessage => 'Track your diet, water, sleep, and workouts in one place, and stay consistent day after day.';

  @override
  String get onboardingAccountBenefitMessage =>
      'Create a free account to keep your data safe and access it from any device. Without one, your data stays on this device only.';

  @override
  String get onboardingCreateAccountAction => 'Create account';

  @override
  String get onboardingContinueWithoutAccountAction => 'Continue without an account';

  @override
  String get settingsAuthLabel => 'Account';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSignInAction => 'Sign in or create account';

  @override
  String get profileGuestTitle => 'Guest';

  @override
  String get profileMacroGoalsSubtitle => 'Your daily calorie and macro targets';

  @override
  String get profileSettingsSubtitle => 'Language, theme and units';

  @override
  String get macroGoalsTitle => 'Macro goals';

  @override
  String get macroGoalsCalorieLabel => 'Calorie goal (kcal)';

  @override
  String get macroGoalsProteinLabel => 'Protein goal (g)';

  @override
  String get macroGoalsCarbsLabel => 'Carbs goal (g)';

  @override
  String get macroGoalsFatLabel => 'Fat goal (g)';

  @override
  String get macroGoalsFiberLabel => 'Fiber goal (g)';

  @override
  String get macroGoalsInvalid => 'Fill in all goals with valid numbers greater than zero.';

  @override
  String get authAnonymousMessage =>
      'Your data stays on this device only. Create an account to keep it safe and access it from any device.';

  @override
  String authSignedInAsLabel(String email) {
    return 'Signed in as $email';
  }

  @override
  String get authCreateAction => 'Create account';

  @override
  String get authLoginAction => 'Log in';

  @override
  String get authLogoutAction => 'Log out';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authSignUpAction => 'Sign up';

  @override
  String get authSignInAction => 'Log in';

  @override
  String get authInvalidEmailMessage => 'Enter a valid email address.';

  @override
  String get authInvalidPasswordMessage => 'Password must be at least 6 characters.';
}
