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
  String get errorTitle => 'Something went wrong';

  @override
  String get warningTitle => 'Almost there';

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
  String get dietIntroTitle => 'Welcome to Diet';

  @override
  String get dietIntroSubtitle => 'Log what you eat, and see your calories and macros come together day by day.';

  @override
  String get dietIntroLogTitle => 'Log your food';

  @override
  String get dietIntroLogMessage =>
      'Search a shared catalog, scan a nutrition label, or add a custom food — then log it by weight or by the unit.';

  @override
  String get dietIntroRecipeTitle => 'Build recipes';

  @override
  String get dietIntroRecipeMessage =>
      'Save meals you eat often as a recipe, then log the whole thing in one tap instead of adding each ingredient.';

  @override
  String get dietIntroTrackTitle => 'Track your progress';

  @override
  String get dietIntroTrackMessage => 'Every log rolls up into your daily calories and macros, a calendar, and trends over time.';

  @override
  String get dietIntroGoalsTitle => 'Set a goal that fits you';

  @override
  String get dietIntroGoalsMessage =>
      'Your calorie and macro targets drive everything here. Aiming to lose weight? Set a target below what you burn to create a deficit — you can fine-tune it any time.';

  @override
  String get dietIntroSetGoalsAction => 'Set my goals';

  @override
  String get dietIntroSkipAction => 'Skip for now';

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
  String get dietUnitsUnit => 'un';

  @override
  String dietLogSubtitleUnits(String units, int calories) {
    return '$units un - $calories kcal';
  }

  @override
  String get dietGramsPerUnitLabel => 'Weight of one unit (g)';

  @override
  String get dietGramsPerUnitHint => 'Optional. Fill it in to log this food by unit, like \"2 eggs\".';

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
  String get dietNutritionScanNoDataTitle => 'Couldn\'t read the label';

  @override
  String get dietNutritionScanNoData => 'Enter the values manually, or try another photo.';

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
  String get dietRecentSearchesTitle => 'Recent searches';

  @override
  String get dietClearRecentSearchesAction => 'Clear';

  @override
  String get dietRemoveRecentSearchTooltip => 'Remove from recent searches';

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
  String get waterHistoryTitle => 'History';

  @override
  String get sleepHistoryTitle => 'History';

  @override
  String get sleepDurationTrendTitle => 'Time asleep';

  @override
  String sleepTrendAverageLabel(String hours) {
    return '$hours h/night average';
  }

  @override
  String get sleepTrendEmptyMessage => 'Nothing logged in this period yet.';

  @override
  String sleepHoursShort(String hours) {
    return '${hours}h';
  }

  @override
  String sleepWeekAverageTooltip(String hours, int days) {
    return 'Weekly average: $hours h over $days logged nights';
  }

  @override
  String get sleepQualitySplitTitle => 'Quality';

  @override
  String sleepRatedNights(int nights) {
    return '$nights rated nights';
  }

  @override
  String get sleepQualityEmptyMessage => 'No nights rated in this period yet.';

  @override
  String sleepQualityStars(int rating) {
    return '$rating stars';
  }

  @override
  String get sleepGoalDialogTitle => 'Nightly sleep goal';

  @override
  String get sleepGoalLabel => 'Hours per night';

  @override
  String get sleepGoalInvalid => 'Enter a number of hours greater than zero.';

  @override
  String get waterTrendTitle => 'Water';

  @override
  String waterTrendAverageLabel(int ml) {
    return '$ml ml/day average';
  }

  @override
  String get waterTrendEmptyMessage => 'Nothing logged in this period yet.';

  @override
  String waterWeekAverageShort(int ml) {
    return '$ml';
  }

  @override
  String waterWeekAverageTooltip(int ml, int days) {
    return 'Weekly average: $ml ml over $days logged days';
  }

  @override
  String trendRangeDays(int days) {
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
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count foods', one: '1 food', zero: 'No foods');
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
      zero: 'No meals added',
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
  String get waterQuickAddLabel => 'Quick add';

  @override
  String waterOfGoal(String goal, String unit) {
    return 'of $goal $unit';
  }

  @override
  String waterLeft(String amount, String unit) {
    return '$amount $unit left';
  }

  @override
  String get waterGoalReached => 'Goal reached!';

  @override
  String get waterGoalMetric => 'Goal';

  @override
  String get waterLogsMetric => 'Logs';

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
  String get macroGoalsEditTooltip => 'Edit goals';

  @override
  String get macroGoalsCalorieTargetTitle => 'Calorie target';

  @override
  String get macroGoalsCalorieTargetHint => 'Calculated from your macros';

  @override
  String get macroGoalsCalorieMinLabel => 'Min';

  @override
  String get macroGoalsCalorieMaxLabel => 'Max';

  @override
  String macroGoalsKcal(int value) {
    return '$value kcal';
  }

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

  @override
  String get authDisplayNameLabel => 'Display name';

  @override
  String get authAvatarLabel => 'Avatar';

  @override
  String get authHasAccountAction => 'Already have an account? Log in';

  @override
  String get authNoAccountAction => 'No account yet? Sign up';

  @override
  String get authPickAvatarAction => 'Choose an avatar';

  @override
  String get authRemoveAvatarAction => 'Remove';

  @override
  String get signInTitle => 'Log in';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get profileAvatarPickerTitle => 'Choose an avatar';

  @override
  String get profileEditAction => 'Edit profile';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get editProfileSaveAction => 'Save';

  @override
  String get profileUpdatedToast => 'Profile updated';

  @override
  String get profileUpdatedToastMessage => 'Your changes were saved.';

  @override
  String get muscleGroupAbdominals => 'Abs';

  @override
  String get muscleGroupAbductors => 'Abductors';

  @override
  String get muscleGroupAdductors => 'Adductors';

  @override
  String get muscleGroupBiceps => 'Biceps';

  @override
  String get muscleGroupCalves => 'Calves';

  @override
  String get muscleGroupChest => 'Chest';

  @override
  String get muscleGroupForearms => 'Forearms';

  @override
  String get muscleGroupGlutes => 'Glutes';

  @override
  String get muscleGroupHamstrings => 'Hamstrings';

  @override
  String get muscleGroupLats => 'Lats';

  @override
  String get muscleGroupLowerBack => 'Lower back';

  @override
  String get muscleGroupMiddleBack => 'Middle back';

  @override
  String get muscleGroupNeck => 'Neck';

  @override
  String get muscleGroupQuadriceps => 'Quads';

  @override
  String get muscleGroupShoulders => 'Shoulders';

  @override
  String get muscleGroupTraps => 'Traps';

  @override
  String get muscleGroupTriceps => 'Triceps';

  @override
  String get bodyRegionChest => 'Chest';

  @override
  String get bodyRegionBack => 'Back';

  @override
  String get bodyRegionShoulders => 'Shoulders';

  @override
  String get bodyRegionArms => 'Arms';

  @override
  String get bodyRegionCore => 'Core';

  @override
  String get bodyRegionLegs => 'Legs';

  @override
  String get exerciseCategoryStrength => 'Strength';

  @override
  String get exerciseCategoryCardio => 'Cardio';

  @override
  String get exerciseCategoryStretching => 'Stretching';

  @override
  String get exerciseCategoryPlyometrics => 'Plyometrics';

  @override
  String get exerciseCategoryPowerlifting => 'Powerlifting';

  @override
  String get exerciseCategoryOlympicWeightlifting => 'Olympic weightlifting';

  @override
  String get exerciseCategoryStrongman => 'Strongman';

  @override
  String get exerciseLevelBeginner => 'Beginner';

  @override
  String get exerciseLevelIntermediate => 'Intermediate';

  @override
  String get exerciseLevelExpert => 'Expert';

  @override
  String get equipmentBarbell => 'Barbell';

  @override
  String get equipmentDumbbell => 'Dumbbell';

  @override
  String get equipmentKettlebells => 'Kettlebell';

  @override
  String get equipmentCable => 'Cable';

  @override
  String get equipmentMachine => 'Machine';

  @override
  String get equipmentBands => 'Bands';

  @override
  String get equipmentBodyOnly => 'Bodyweight';

  @override
  String get equipmentExerciseBall => 'Exercise ball';

  @override
  String get equipmentMedicineBall => 'Medicine ball';

  @override
  String get equipmentFoamRoll => 'Foam roller';

  @override
  String get equipmentEzCurlBar => 'EZ curl bar';

  @override
  String get equipmentOther => 'Other';

  @override
  String get workoutTodayTitle => 'Today';

  @override
  String get workoutPreviousDayTooltip => 'Previous day';

  @override
  String get workoutNextDayTooltip => 'Next day';

  @override
  String get workoutAddExercise => 'Add exercise';

  @override
  String get workoutEmptyTitle => 'No workout logged';

  @override
  String get workoutEmptyMessage => 'Add an exercise to start today\'s workout.';

  @override
  String get workoutIntroTitle => 'Welcome to Workout';

  @override
  String get workoutIntroSubtitle => 'Log your training, watch your numbers climb, and let the app plan what\'s next.';

  @override
  String get workoutIntroLogTitle => 'Log every set';

  @override
  String get workoutIntroLogMessage => 'Add exercises and record reps and load — sets are pre-filled from last time so you just adjust.';

  @override
  String get workoutIntroProgressTitle => 'See your progress';

  @override
  String get workoutIntroProgressMessage => 'Volume, history and per-exercise progression build up automatically as you train.';

  @override
  String get workoutIntroRoutineTitle => 'What is a routine?';

  @override
  String get workoutIntroRoutineMessage =>
      'A routine is a named, ordered list of exercises — like \"Push — chest & triceps\". Your routines form a cycle, and the app suggests which one to train next, so you never wonder what\'s on today.';

  @override
  String get workoutIntroCreateRoutineAction => 'Create my first routine';

  @override
  String get workoutIntroSkipAction => 'Skip for now';

  @override
  String get workoutVolumeLabel => 'Volume';

  @override
  String get workoutSetsLabel => 'Sets';

  @override
  String get workoutRepsLabel => 'Reps';

  @override
  String get workoutExercisesLabel => 'exercises';

  @override
  String workoutExercisesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count to go', one: '1 to go', zero: 'All done');
    return '$_temp0';
  }

  @override
  String workoutLoadLabel(String unit) {
    return 'Load ($unit)';
  }

  @override
  String get workoutLoadHelper => 'Leave the load empty for a bodyweight set.';

  @override
  String get workoutTotalRepsLabel => 'Total reps';

  @override
  String get workoutHeaviestLabel => 'Heaviest';

  @override
  String get workoutAddSet => 'Add set';

  @override
  String get workoutEditSet => 'Edit set';

  @override
  String get workoutLogSetAction => 'Save set';

  @override
  String get workoutDeleteSetTooltip => 'Remove set';

  @override
  String get workoutDeleteExercise => 'Remove exercise';

  @override
  String get workoutDeleteWorkout => 'Delete workout';

  @override
  String get workoutDeleteWorkoutMessage => 'This deletes every exercise and set logged on this day.';

  @override
  String get workoutNoSetsMessage => 'No sets yet.';

  @override
  String get workoutBodyweightLabel => 'Bodyweight';

  @override
  String get workoutInvalidRepsMessage => 'Enter how many reps you did.';

  @override
  String get workoutInvalidLoadMessage => 'Enter a valid load, or leave it empty for bodyweight.';

  @override
  String workoutSetSummary(int reps) {
    return '$reps reps';
  }

  @override
  String workoutLastTimeLabel(String summary) {
    return 'Last time: $summary';
  }

  @override
  String workoutSetsSummaryUniform(int sets, int reps) {
    return '$sets×$reps';
  }

  @override
  String workoutSetsSummaryMixed(int sets) {
    String _temp0 = intl.Intl.pluralLogic(sets, locale: localeName, other: '$sets sets', one: '1 set', zero: 'no sets');
    return '$_temp0';
  }

  @override
  String get exerciseSearchTitle => 'Exercises';

  @override
  String get exerciseSearchHint => 'Search exercises';

  @override
  String get exerciseSearchEmptyTitle => 'No exercises found';

  @override
  String get exerciseSearchEmptyMessage => 'Try another term or clear the muscle filter.';

  @override
  String get exerciseSearchAllFilter => 'All';

  @override
  String get exerciseDetailInstructionsTitle => 'How to do it';

  @override
  String get exerciseDetailPrimaryMusclesTitle => 'Primary muscles';

  @override
  String get exerciseDetailSecondaryMusclesTitle => 'Also works';

  @override
  String get exerciseDetailNoInstructionsMessage => 'This exercise has no instructions yet.';

  @override
  String get exerciseDetailAddAction => 'Add to workout';

  @override
  String get workoutRoutinesTitle => 'Routines';

  @override
  String get workoutRoutinesTooltip => 'Routines';

  @override
  String get workoutRoutinesEmptyTitle => 'No routines yet';

  @override
  String get workoutRoutinesEmptyMessage => 'Build your A/B/C split and the app tells you which one is next.';

  @override
  String get workoutRoutineNewAction => 'New routine';

  @override
  String get workoutRoutineNameLabel => 'Routine name';

  @override
  String get workoutRoutineNameHint => 'Workout A — Chest and triceps';

  @override
  String get workoutRoutineExercisesTitle => 'Exercises';

  @override
  String get workoutRoutineAddExerciseAction => 'Add exercise';

  @override
  String get workoutRoutineSaveAction => 'Save routine';

  @override
  String get workoutRoutineDeleteTooltip => 'Remove';

  @override
  String get workoutRoutineRemoveExerciseTooltip => 'Remove from routine';

  @override
  String get workoutRoutineIncompleteMessage => 'Give the routine a name and at least one exercise.';

  @override
  String workoutRoutineExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count exercises', one: '1 exercise', zero: 'No exercises');
    return '$_temp0';
  }

  @override
  String get workoutNextRoutineLabel => 'Next up';

  @override
  String workoutStartRoutineAction(String name) {
    return 'Start $name';
  }

  @override
  String get workoutRoutineLastTrainedNever => 'Not trained yet';

  @override
  String workoutFromRoutineLabel(String name) {
    return 'From $name';
  }

  @override
  String get workoutStartRoutineHint => 'Sets are pre-filled with your last session — adjust what changed.';

  @override
  String get reorderHandleLabel => 'Reorder';

  @override
  String get workoutRepeatSetAction => 'Repeat set';

  @override
  String get workoutRepeatSetTooltip => 'Repeat the last set';

  @override
  String get workoutCompleteExerciseAction => 'Done';

  @override
  String get workoutReopenExerciseAction => 'Reopen';

  @override
  String workoutCompletedSummary(int sets) {
    String _temp0 = intl.Intl.pluralLogic(sets, locale: localeName, other: '$sets sets done', one: '1 set done', zero: 'No sets');
    return '$_temp0';
  }

  @override
  String get workoutFinishedTitle => 'Workout done';

  @override
  String get workoutFinishedMessage => 'Every exercise is checked off. Well done — see you next session.';

  @override
  String get workoutCompleteNeedsSetTooltip => 'Log a set before finishing this exercise';

  @override
  String get workoutProgressionTitle => 'Progression';

  @override
  String get workoutProgressionEmptyTitle => 'No history yet';

  @override
  String get workoutProgressionEmptyMessage => 'Log this exercise in a few workouts and its load progression shows up here.';

  @override
  String get workoutProgressionRecordsTitle => 'Personal records';

  @override
  String get workoutProgressionBestE1rmLabel => 'Best est. 1RM';

  @override
  String get workoutProgressionHeaviestLabel => 'Heaviest load';

  @override
  String get workoutProgressionE1rmTitle => 'Estimated 1RM';

  @override
  String get workoutProgressionHeaviestTitle => 'Heaviest load';

  @override
  String workoutProgressionSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Last $count sessions',
      one: 'Last session',
      zero: 'No sessions',
    );
    return '$_temp0';
  }

  @override
  String get workoutProgressionListTitle => 'Progress';

  @override
  String get workoutProgressionListEmptyTitle => 'No exercises logged yet';

  @override
  String get workoutProgressionListEmptyMessage =>
      'Log a few workouts and the exercises you trained show up here to track their progression.';

  @override
  String get workoutHistoryTitle => 'History';

  @override
  String workoutHistoryWeekSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count workouts', one: '1 workout', zero: 'No workouts');
    return '$_temp0';
  }

  @override
  String get workoutVolumeTrendTitle => 'Volume per session';

  @override
  String workoutVolumeAverageLabel(String value) {
    return '$value avg';
  }

  @override
  String workoutHistoryVolumeSummary(int sessions, int sets) {
    String _temp0 = intl.Intl.pluralLogic(sessions, locale: localeName, other: '$sessions sessions', one: '1 session', zero: 'No sessions');
    String _temp1 = intl.Intl.pluralLogic(sets, locale: localeName, other: '$sets sets', one: '1 set', zero: 'no sets');
    return '$_temp0 · $_temp1';
  }

  @override
  String get workoutMuscleSplitTitle => 'Volume by muscle group';

  @override
  String get workoutMuscleSplitEmptyMessage => 'No load lifted in this period. Weighted sets show their muscle-group split here.';
}
