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
  String get dietEmptyMessage => 'Tap the + button to add the first food of the day.';

  @override
  String get dietInvalidQuantity => 'Enter a quantity greater than zero.';

  @override
  String dietQuantityLabel(String unit) {
    return 'Quantity ($unit)';
  }

  @override
  String get dietLogFoodAction => 'Add to today';

  @override
  String get dietInvalidCustomFood => 'Fill in the name and all macros with valid numbers.';

  @override
  String get dietCustomFoodTitle => 'Add a food';

  @override
  String get dietFoodNameLabel => 'Name';

  @override
  String get dietCaloriesPer100gLabel => 'Calories per 100g';

  @override
  String get dietProteinPer100gLabel => 'Protein per 100g';

  @override
  String get dietCarbsPer100gLabel => 'Carbs per 100g';

  @override
  String get dietFatPer100gLabel => 'Fat per 100g';

  @override
  String get dietFiberPer100gLabel => 'Fiber per 100g';

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
  String get dietTakePhotoAction => 'Take photo';

  @override
  String get dietChooseFromGalleryAction => 'Choose from gallery';

  @override
  String get dietContinueAction => 'Continue';

  @override
  String dietCaloriesPer100g(int calories) {
    return '$calories kcal / 100g';
  }

  @override
  String get dietFoodSearchTitle => 'Search foods';

  @override
  String get dietSearchFieldLabel => 'Search Open Food Facts';

  @override
  String get dietSearchPrompt => 'Search for a food to log it.';

  @override
  String get dietSearchNoResults => 'No results. Try another search or add it manually.';

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
