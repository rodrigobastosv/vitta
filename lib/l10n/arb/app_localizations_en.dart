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
  String get homeTagline => 'Your companion for a healthier day.';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get reminderFeatureTitle => 'Reminders';

  @override
  String get reminderFeatureSubtitle => 'Keep track of things to do';

  @override
  String get reminderTitle => 'Reminders';

  @override
  String get reminderAddAction => 'Add reminder';

  @override
  String get reminderHistoryTitle => 'History';

  @override
  String get reminderFilterAll => 'All';

  @override
  String get reminderFilterCompleted => 'Completed';

  @override
  String get reminderFilterActive => 'Active';

  @override
  String get reminderEmptyTitle => 'No reminders';

  @override
  String get reminderEmptyMessage => 'Add a reminder for this day and it\'ll be waiting for you here.';

  @override
  String get reminderNewTitle => 'New reminder';

  @override
  String get reminderEditTitle => 'Edit reminder';

  @override
  String get reminderTitleLabel => 'Title';

  @override
  String get reminderTitleHint => 'Pay the electricity bill, ...';

  @override
  String get reminderNotesLabel => 'Notes (optional)';

  @override
  String get reminderDueDateLabel => 'Date';

  @override
  String get reminderRemindLabel => 'Remind me';

  @override
  String get reminderRepeatLabel => 'Repeat';

  @override
  String get reminderRepeatNever => 'Never';

  @override
  String get reminderRepeatDaily => 'Daily';

  @override
  String get reminderRepeatWeekly => 'Weekly';

  @override
  String get reminderRepeatMonthly => 'Monthly';

  @override
  String get reminderDeleteTooltip => 'Delete';

  @override
  String get reminderCompleteAction => 'Complete';

  @override
  String get reminderOverdueBadge => 'Overdue';

  @override
  String get reminderPreviousDayTooltip => 'Previous day';

  @override
  String get reminderNextDayTooltip => 'Next day';

  @override
  String get reminderToday => 'Today';

  @override
  String get reminderTomorrow => 'Tomorrow';

  @override
  String get reminderYesterday => 'Yesterday';

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
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get increase => 'Increase';

  @override
  String get decrease => 'Decrease';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get dietHistoryEmptyTitle => 'No meals logged yet';

  @override
  String get dietHistoryEmptyMessage => 'Log a few days of meals and your calendar, trends and meal split will show up here.';

  @override
  String get dietHistoryEmptyAction => 'Log a meal';

  @override
  String get waterHistoryEmptyTitle => 'No water logged yet';

  @override
  String get waterHistoryEmptyMessage => 'Track a few days and you\'ll see how your intake trends against your goal.';

  @override
  String get waterHistoryEmptyAction => 'Log water';

  @override
  String get sleepHistoryEmptyTitle => 'No nights logged yet';

  @override
  String get sleepHistoryEmptyMessage => 'Log a few nights and your duration trend and quality split will show up here.';

  @override
  String get sleepHistoryEmptyAction => 'Log sleep';

  @override
  String get workoutHistoryEmptyTitle => 'No sessions logged yet';

  @override
  String get workoutHistoryEmptyMessage => 'Train a few sessions and you\'ll see your volume trend and which muscles you\'re hitting.';

  @override
  String get workoutHistoryEmptyAction => 'Start a workout';

  @override
  String get reminderHistoryEmptyTitle => 'Nothing this month';

  @override
  String get reminderHistoryEmptyMessage =>
      'Reminders you create will show up on this calendar, so you can look back at what you got done.';

  @override
  String get reminderHistoryEmptyAction => 'Create a reminder';

  @override
  String get bodyWeightHistoryEmptyAction => 'Log your weight';

  @override
  String get reminderFilterNoResultsTitle => 'Nothing matches this filter';

  @override
  String get reminderFilterNoResultsMessage => 'You have reminders on this day, just none in this view. Try another filter.';

  @override
  String get homeTodayTitle => 'Today';

  @override
  String get homeAlsoTodayTitle => 'Also today';

  @override
  String get homeTrackTitle => 'Track';

  @override
  String homeMealsLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals logged',
      one: '1 meal logged',
      zero: 'Nothing logged yet',
    );
    return '$_temp0';
  }

  @override
  String homeWaterLeft(String amount, String unit) {
    return '$amount $unit to go';
  }

  @override
  String get homeWaterDone => 'Goal reached';

  @override
  String get homeNextReminder => 'Next reminder';

  @override
  String get homeNoReminders => 'Nothing due today';

  @override
  String homeWorkoutProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get homeNoWorkout => 'Nothing logged today';

  @override
  String get homeSleepLastNight => 'Last night';

  @override
  String get homeWeightLatest => 'Latest';

  @override
  String get homeNotTrackedYet => 'Not tracked yet';

  @override
  String homeSleepGoal(String hours) {
    return 'Goal ${hours}h';
  }

  @override
  String get homeWorkoutHeroTitle => 'Today\'s session';

  @override
  String homeRemindersOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count still to do',
      one: '1 still to do',
      zero: 'All done for today',
    );
    return '$_temp0';
  }

  @override
  String homeRemindersMore(int count) {
    return '+$count more';
  }

  @override
  String get homeWeightTrendTitle => 'Weight trend';

  @override
  String get homeLayoutTitle => 'Home screen';

  @override
  String get homeLayoutMessage => 'Drag to reorder. Tap a feature to choose where it shows up.';

  @override
  String homeLayoutSlotQuestion(String feature) {
    return 'Where should $feature appear?';
  }

  @override
  String get homeLayoutResetMessage => 'Your home screen is back to the default order.';

  @override
  String get homeLayoutResetAction => 'Reset to default';

  @override
  String get homeSlotHero => 'Headline';

  @override
  String get homeSlotSupporting => 'Supporting row';

  @override
  String get homeSlotTile => 'Tile';

  @override
  String get homeSlotHidden => 'Hidden';

  @override
  String get settingsHomeLayoutLabel => 'Home screen';

  @override
  String get settingsHomeLayoutHint => 'Pick what leads, what supports it and what stays hidden';

  @override
  String get onboardingFeaturesTitle => 'Many things, one app';

  @override
  String get onboardingGoalsTitle => 'Set a daily calorie target';

  @override
  String get onboardingGoalsMessage => 'You can change this any time, and we\'ll split it into protein, carbs and fat for you.';

  @override
  String get onboardingGoalsSkipAction => 'Skip for now';

  @override
  String onboardingGoalsSuggestedFor(String objective) {
    return 'Suggested for $objective';
  }

  @override
  String get onboardingBodyTitle => 'Tell us about you';

  @override
  String get onboardingBodyMessage =>
      'Your weight and height let us suggest a calorie target. We\'ll save this weight as your first entry.';

  @override
  String get onboardingWeightLabel => 'Current weight';

  @override
  String get onboardingHeightLabel => 'Height';

  @override
  String get onboardingObjectiveTitle => 'What are you aiming for?';

  @override
  String get objectiveTitle => 'Your objective';

  @override
  String get objectiveMessage =>
      'Your objective sets your daily calorie target and how it splits into protein, carbs and fat. Change it whenever your training does.';

  @override
  String get objectiveTargetTitle => 'Daily calorie target';

  @override
  String objectiveWeightFromLatest(String weight) {
    return 'From your latest weigh-in, $weight';
  }

  @override
  String objectiveWeightAssumed(String weight) {
    return 'Assuming $weight — log a weight for a target built on yours';
  }

  @override
  String get bodyProfileSexTitle => 'Biological sex';

  @override
  String get bodyProfileSexHint => 'Men and women burn different amounts at rest, so this moves the estimate.';

  @override
  String get bodyProfileSexMale => 'Male';

  @override
  String get bodyProfileSexFemale => 'Female';

  @override
  String get bodyProfileAgeLabel => 'Age';

  @override
  String bodyProfileAgeValue(int years) {
    return '$years yrs';
  }

  @override
  String get bodyProfileActivityTitle => 'Activity level';

  @override
  String get bodyProfileActivityHint => 'How much you move on an ordinary day, training included.';

  @override
  String get bodyProfileActivitySedentary => 'Sedentary';

  @override
  String get bodyProfileActivityLightlyActive => 'Lightly active';

  @override
  String get bodyProfileActivityModeratelyActive => 'Moderately active';

  @override
  String get bodyProfileActivityVeryActive => 'Very active';

  @override
  String get bodyProfileActivityExtraActive => 'Extra active';

  @override
  String get bodyProfileMetabolismTitle => 'Basal metabolism';

  @override
  String bodyProfileMetabolismBasal(int calories) {
    return '$calories kcal at rest';
  }

  @override
  String bodyProfileMetabolismMaintenance(int calories) {
    return '$calories kcal to maintain';
  }

  @override
  String get bodyProfileMetabolismMethod => 'Mifflin-St Jeor, multiplied by your activity level.';

  @override
  String get bodyProfileMetabolismMeasured => 'Worked out from your weight, height, sex, age and activity level.';

  @override
  String get bodyProfileMetabolismAssumed => 'Part of this is assumed — fill in your sex, age and activity level for a closer figure.';

  @override
  String get objectiveOverwritesGoalsNote => 'Saving replaces your macro goals. You can still fine-tune them from the diet page.';

  @override
  String get objectiveSaveAction => 'Save objective';

  @override
  String get objectiveSavedTitle => 'Objective updated';

  @override
  String get objectiveSavedMessage => 'Your calorie target and macros now follow it.';

  @override
  String get profileObjectiveSubtitle => 'Set your goal and recalculate your targets';

  @override
  String get onboardingObjectiveLoseWeight => 'Lose weight';

  @override
  String get onboardingObjectiveLoseWeightMessage => 'Eat under maintenance, keep the protein high';

  @override
  String get onboardingObjectiveMaintainWeight => 'Maintain weight';

  @override
  String get onboardingObjectiveMaintainWeightMessage => 'Stay where you are, with a balanced split';

  @override
  String get onboardingObjectiveGainMuscle => 'Gain muscle';

  @override
  String get onboardingObjectiveGainMuscleMessage => 'Eat a little over maintenance to build';

  @override
  String get onboardingAccountTitle => 'Keep your data safe';

  @override
  String get onboardingNextAction => 'Next';

  @override
  String get onboardingBackAction => 'Back';

  @override
  String get delete => 'Delete';

  @override
  String get dietRecipeBadge => 'Recipe';

  @override
  String get dietCommonFoodBadge => 'Common';

  @override
  String dietQuantityUnits(String units) {
    return '$units un';
  }

  @override
  String dietQuantityGrams(int grams) {
    return '$grams g';
  }

  @override
  String get dietLogAgainAction => 'Log again';

  @override
  String get dietRecentlyLoggedTitle => 'Recently logged';

  @override
  String get dietRecentSearchesTitle => 'Recent searches';

  @override
  String get dietRecentTabLabel => 'Recent';

  @override
  String get dietRecentEmptyTitle => 'Nothing logged yet';

  @override
  String get dietRecentEmptyMessage => 'Foods you log will show up here, ready to add again in one tap.';

  @override
  String get dietCopyMealsEmptyDayTitle => 'Nothing logged that day';

  @override
  String get dietCopyMealsEmptyDayMessage => 'Pick another day — this one has no meals to copy.';

  @override
  String get workoutRestTimerLabel => 'Rest';

  @override
  String get workoutRestExtendAction => '+30s';

  @override
  String get workoutRestSkipAction => 'Skip';

  @override
  String get workoutNoSetsYet => 'No sets logged yet.';

  @override
  String get workoutInstructionsTitle => 'How to';

  @override
  String get workoutRestShortenAction => 'Take 30 seconds off';

  @override
  String get workoutRestConfigureAction => 'Rest length';

  @override
  String get workoutRestSettingTitle => 'Rest between sets';

  @override
  String get workoutRestSettingHint => 'Used every time you log a set.';

  @override
  String get workoutLastSetPrefillNote => 'Prefilled from your last set';

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
  String get dietEmptyMessage => 'Add what you ate and your calories and macros fill in as you go.';

  @override
  String get dietNotTodayEmptyMessage => 'Nothing was logged on this day. You can still add what you ate.';

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
  String get dietScanLabelAction => 'Scan nutrition label';

  @override
  String get dietNutritionScanNoDataTitle => 'Couldn\'t read the label';

  @override
  String get dietNutritionScanNoData => 'Enter the values manually, or try another photo.';

  @override
  String get dietNutritionScanningCaptionReading => 'Reading the label…';

  @override
  String get dietNutritionScanningCaptionExtracting => 'Extracting the nutrition facts…';

  @override
  String get mealScanTitle => 'Scan a meal';

  @override
  String get mealScanIntroTitle => 'Snap your meal';

  @override
  String get mealScanIntroMessage => 'Take a photo of your plate and we identify the items and estimate their macros for you.';

  @override
  String get mealScanTakePhotoAction => 'Take a photo';

  @override
  String get mealScanRetakeAction => 'Try another photo';

  @override
  String get mealScanNoDataTitle => 'No food detected';

  @override
  String get mealScanNoData =>
      'We couldn\'t spot any food in that photo. Frame the whole plate in good light, get a little closer, and try again.';

  @override
  String get mealScanScanningCaptionLooking => 'Looking at your plate…';

  @override
  String get mealScanScanningCaptionIdentifying => 'Identifying the food…';

  @override
  String get mealScanScanningCaptionEstimating => 'Estimating portions…';

  @override
  String get mealScanItemsTitle => 'Detected items';

  @override
  String mealScanFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Found $count items', one: 'Found 1 item');
    return '$_temp0';
  }

  @override
  String mealScanEstimatedTotal(int calories) {
    return '~$calories kcal estimated';
  }

  @override
  String get mealScanPortionLabel => 'Portion';

  @override
  String get mealScanItemsSubtitle =>
      'These macros are estimates — adjust the amounts, untick anything you don\'t want, then add it to your day.';

  @override
  String get mealScanMealTypeTitle => 'Add to meal';

  @override
  String get mealScanLogAction => 'Add to diary';

  @override
  String get mealScanIncomplete => 'Pick at least one item with a valid amount.';

  @override
  String get mealScanLoggedTitle => 'Meal added';

  @override
  String get mealScanLoggedMessage => 'Everything you kept is now in your day.';

  @override
  String dietCaloriesPer100g(int calories) {
    return '$calories kcal / 100g';
  }

  @override
  String get dietFoodSearchTitle => 'Add food';

  @override
  String get dietFavoritesTitle => 'Favorites';

  @override
  String get dietSearchTabLabel => 'Search';

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
  String get dietSearchFieldLabel => 'Search foods';

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
  String get dietRecipesEmptyMessage => 'Combine foods you eat together into a recipe, then log the whole thing in one go.';

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
  String get dietRecipeAddToMealAction => 'Add to meal';

  @override
  String dietRecipeIngredientCount(int count, int grams) {
    return '$count ingredients - $grams g';
  }

  @override
  String get dietPickIngredientTitle => 'Pick a food';

  @override
  String get dietRecipeSubtitle => 'Recipes are yours only and never show up in anyone else\'s search.';

  @override
  String get dietRecipeLogHint => 'Tap Add to meal to log the whole recipe, or search it by name in Add food.';

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
  String get waterEmptyMessage => 'Use a quick add above to log your first glass of the day.';

  @override
  String get bodyWeightFeatureTitle => 'Body weight';

  @override
  String get bodyWeightFeatureSubtitle => 'Track your weight over time';

  @override
  String get bodyWeightHistoryTitle => 'Weight history';

  @override
  String get bodyWeightCurrentTitle => 'Current weight';

  @override
  String get bodyWeightEmptyTitle => 'No weight logged yet';

  @override
  String get bodyWeightEmptyMessage => 'Log your weight to start tracking your progress.';

  @override
  String get bodyWeightLogAction => 'Log weight';

  @override
  String get bodyWeightDateLabel => 'Date';

  @override
  String bodyWeightValue(String value, String unit) {
    return '$value $unit';
  }

  @override
  String get bodyWeightRecentTitle => 'Recent entries';

  @override
  String get bodyWeightTrendTitle => 'Trend';

  @override
  String get bodyWeightStatMin => 'Min';

  @override
  String get bodyWeightStatMax => 'Max';

  @override
  String get bodyWeightStatAverage => 'Average';

  @override
  String get bodyWeightStatChange => 'Change';

  @override
  String get bodyWeightHistoryEmptyTitle => 'No weight in this range';

  @override
  String get bodyWeightHistoryEmptyMessage => 'Log your weight to see your trend.';

  @override
  String get workoutBodyweightPrefillNote => 'Prefilled with your latest body weight';

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
  String get sleepEmptyMessage => 'Log a night and you\'ll start seeing how your rest compares to your goal.';

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
  String sleepHoursOnly(int hours) {
    return '${hours}h';
  }

  @override
  String sleepMinutesOnly(int minutes) {
    return '${minutes}m';
  }

  @override
  String get sleepLastNightLabel => 'Last night';

  @override
  String get sleepGoalReached => 'Goal met!';

  @override
  String sleepShort(String duration) {
    return '$duration short';
  }

  @override
  String sleepOfGoal(String duration) {
    return 'of $duration';
  }

  @override
  String get sleepGoalMetric => 'Goal';

  @override
  String get sleepAverageMetric => 'Average';

  @override
  String get sleepNightsMetric => 'Nights';

  @override
  String get sleepSyncedTitle => 'Sleep synced';

  @override
  String get sleepSyncTooltip => 'Sync from health app';

  @override
  String get sleepSyncDebugTooltip => 'Insert sample sleep (debug)';

  @override
  String sleepImportedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nights imported',
      one: '1 night imported',
      zero: 'No new sleep to import',
    );
    return '$_temp0';
  }

  @override
  String get sleepHealthUnavailableMessage =>
      'Sleep data isn\'t available on this device. Set up Health Connect (Android) or Apple Health (iOS) first.';

  @override
  String get sleepHealthPermissionDeniedMessage => 'Sleep permission was denied. Grant it to import your nights.';

  @override
  String get sleepSourceHealth => 'Health';

  @override
  String get sleepSyncStatusTitle => 'Health app';

  @override
  String sleepLastSyncedLabel(String when) {
    return 'Last synced $when';
  }

  @override
  String get sleepSyncNowTooltip => 'Sync now';

  @override
  String get sleepLogDurationHint => 'Time asleep';

  @override
  String get sleepQualityPoor => 'Poor';

  @override
  String get sleepQualityFair => 'Fair';

  @override
  String get sleepQualityGood => 'Good';

  @override
  String get sleepQualityGreat => 'Great';

  @override
  String get sleepQualityExcellent => 'Excellent';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Vitta';

  @override
  String get onboardingWelcomeMessage =>
      'Food, workouts, water, sleep, weight and reminders — all in one place, so staying consistent gets easier day after day.';

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
  String get profileSettingsSubtitle => 'Language, theme and units';

  @override
  String get premiumTitle => 'Vitta Premium';

  @override
  String get premiumTagline => 'AI-powered tracking, without the typing';

  @override
  String get premiumIntro =>
      'Photo scanning uses AI to read your food for you. It costs real money to run, so it lives behind Premium — everything else in Vitta stays free.';

  @override
  String get premiumFeaturesTitle => 'What you unlock';

  @override
  String get premiumFeatureMealScanTitle => 'Meal photo scan';

  @override
  String get premiumFeatureMealScanSubtitle => 'Photograph a plate and log every item at once';

  @override
  String get premiumFeatureNutritionLabelScanTitle => 'Nutrition label scan';

  @override
  String get premiumFeatureNutritionLabelScanSubtitle => 'Point at a label and fill the macros in for you';

  @override
  String get premiumFreeTitle => 'Free forever';

  @override
  String get premiumFreeMessage =>
      'Food search, the catalog, recipes, water, sleep, workouts, reminders and every history chart stay free.';

  @override
  String get premiumSignUpPrompt => 'A subscription is tied to your account, so you need one first.';

  @override
  String get premiumSignUpAction => 'Create an account';

  @override
  String get premiumActiveTitle => 'Premium active';

  @override
  String get premiumActiveMessage => 'You have full access to the AI scans. Thank you for supporting Vitta.';

  @override
  String premiumRenewsOn(String date) {
    return 'Renews on $date';
  }

  @override
  String get premiumLockedBadge => 'Premium';

  @override
  String get premiumTermsAction => 'Terms of Use';

  @override
  String get premiumPrivacyAction => 'Privacy Policy';

  @override
  String get premiumAutoRenewalDisclosure =>
      'Payment is charged to your Apple ID account at confirmation of purchase. The subscription renews automatically unless it is cancelled at least 24 hours before the end of the current period. Manage or cancel it any time in your App Store account settings.';

  @override
  String get premiumLinkFailed => 'Couldn\'t open that link.';

  @override
  String get premiumSubscribeAction => 'Start Premium';

  @override
  String get premiumRestoreAction => 'Restore purchases';

  @override
  String get premiumUnavailable => 'Subscriptions aren\'t available right now. Try again later.';

  @override
  String get premiumPurchaseFailed => 'The purchase couldn\'t be completed.';

  @override
  String get premiumRestoredTitle => 'Welcome back';

  @override
  String get premiumRestoredMessage => 'Your subscription is active again.';

  @override
  String get premiumNothingToRestore => 'No previous subscription was found for this Apple ID.';

  @override
  String get premiumPurchasedTitle => 'You\'re all set';

  @override
  String get premiumPurchasedMessage => 'The AI scans are unlocked.';

  @override
  String get premiumRequiredTitle => 'Premium required';

  @override
  String get premiumRequiredMessage => 'Your subscription is not active, so this scan was not run.';

  @override
  String get profilePremiumTitle => 'Premium';

  @override
  String get profilePremiumSubtitleActive => 'Subscription active';

  @override
  String get profilePremiumSubtitleFree => 'Unlock the AI photo scans';

  @override
  String get profileDeleteAccountTitle => 'Delete account';

  @override
  String get profileDeleteAccountSubtitle => 'Permanently erase your account and data';

  @override
  String get deleteAccountDialogTitle => 'Delete account?';

  @override
  String get deleteAccountDialogMessage =>
      'This permanently deletes your account and all of your data — meals, workouts, weight, water, sleep and everything else. This can\'t be undone.';

  @override
  String get deleteAccountConfirmAction => 'Delete account';

  @override
  String get profileAccountDeleted => 'Account deleted';

  @override
  String get profileAccountDeletedMessage => 'Your account and all of your data were permanently deleted.';

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
  String get macroGoalsModalityTitle => 'Diet modality';

  @override
  String get macroGoalsModalityHint => 'Pick a preset, then fine-tune below';

  @override
  String get macroGoalsModalityCustom => 'Custom';

  @override
  String get dietModalityBalanced => 'Balanced';

  @override
  String get dietModalityHighProtein => 'High protein';

  @override
  String get dietModalityLowFat => 'Low fat';

  @override
  String get dietModalityLowCarb => 'Low carb';

  @override
  String get dietModalityKeto => 'Keto';

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
  String get profileUpdatedToastMessage => 'Your profile is up to date.';

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
  String get workoutEffortLabel => 'Effort';

  @override
  String get workoutLogEffortAction => 'Log effort';

  @override
  String get workoutEditEffortAction => 'Edit effort';

  @override
  String get workoutSaveEffortAction => 'Save effort';

  @override
  String get workoutNoEffortMessage => 'No effort logged yet.';

  @override
  String get workoutCompleteNeedsEffortTooltip => 'Log the effort before finishing this exercise';

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
  String workoutDurationHm(int hours, int minutes) {
    return '${hours}h ${minutes}min';
  }

  @override
  String workoutDurationMs(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String workoutDurationM(int minutes) {
    return '$minutes min';
  }

  @override
  String workoutDurationS(int seconds) {
    return '$seconds s';
  }

  @override
  String get workoutDurationLabel => 'Duration';

  @override
  String get workoutDurationMinutesLabel => 'Min';

  @override
  String get workoutDurationSecondsLabel => 'Sec';

  @override
  String workoutDistanceLabel(String unit) {
    return 'Distance ($unit)';
  }

  @override
  String get workoutDistanceOptionalHelper => 'Time is required; distance is optional.';

  @override
  String get workoutInvalidDurationMessage => 'Enter how long it lasted.';

  @override
  String get workoutInvalidDistanceMessage => 'Enter a valid distance, or leave it empty.';

  @override
  String get workoutTimeLabel => 'Time';

  @override
  String get workoutDistanceMetricLabel => 'Distance';

  @override
  String get workoutCardioTrendTitle => 'Cardio time';

  @override
  String get workoutCardioTrendEmptyMessage => 'No cardio logged in this period yet.';

  @override
  String get workoutCardioDurationLegend => 'Duration';

  @override
  String workoutCardioTrendAverage(int minutes) {
    return '$minutes min/day avg';
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
  String get workoutSummaryTitle => 'Session summary';

  @override
  String get workoutSummaryHeadline => 'Session done';

  @override
  String get workoutSummaryDoneAction => 'Done';

  @override
  String get workoutSummaryProgressTitle => 'Against last time';

  @override
  String get workoutSummaryProgressFirst => 'First time';

  @override
  String get workoutSummaryProgressFlat => 'Same as last time';

  @override
  String workoutSummaryProgressUpVolume(String delta, String unit) {
    return '+$delta $unit of volume';
  }

  @override
  String workoutSummaryProgressDownVolume(String delta, String unit) {
    return '−$delta $unit of volume';
  }

  @override
  String workoutSummaryProgressUpDuration(int minutes) {
    return '$minutes min longer';
  }

  @override
  String workoutSummaryProgressDownDuration(int minutes) {
    return '$minutes min shorter';
  }

  @override
  String workoutSummaryProgressHeavier(String delta, String unit) {
    return 'Heaviest set up $delta $unit';
  }

  @override
  String workoutSummaryImprovedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises moved up',
      one: '1 exercise moved up',
      zero: 'Nothing moved up this time',
    );
    return '$_temp0';
  }

  @override
  String get workoutSummaryExercisesTitle => 'What you did';

  @override
  String get workoutFinishedTitle => 'Workout done';

  @override
  String get workoutFinishedMessage => 'Every exercise is checked off. Well done — see you next session.';

  @override
  String get workoutSummaryViewAction => 'View summary';

  @override
  String get workoutFinishedCaloriesLabel => 'Estimated burn';

  @override
  String workoutFinishedCaloriesValue(int calories) {
    return '~$calories kcal';
  }

  @override
  String get workoutFinishedCaloriesHint => 'Worked out from your weight, what you trained and how long it takes.';

  @override
  String get workoutFinishedCaloriesNoWeightHint => 'A rough figure — log your body weight for a closer one.';

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

  @override
  String get premiumCancelAnytime => 'Cancel anytime in your App Store settings.';

  @override
  String get premiumOfferRetryAction => 'Try again';

  @override
  String get premiumPeriodWeekly => 'per week';

  @override
  String get premiumPeriodMonthly => 'per month';

  @override
  String get premiumPeriodTwoMonth => 'every 2 months';

  @override
  String get premiumPeriodThreeMonth => 'every 3 months';

  @override
  String get premiumPeriodSixMonth => 'every 6 months';

  @override
  String get premiumPeriodAnnual => 'per year';

  @override
  String get premiumPeriodLifetime => 'one-time payment';

  @override
  String chartTooltipEntry(String date, String value) {
    return '$date · $value';
  }

  @override
  String waterTrendTooltipValue(int ml) {
    return '$ml ml';
  }

  @override
  String chartTooltipMacros(String date, int protein, int carbs, int fat) {
    return '$date\nP ${protein}g · C ${carbs}g · F ${fat}g';
  }

  @override
  String get dietDayReadOnlyBadge => 'View only';

  @override
  String get workoutProgressionRecordLegend => 'Personal record';

  @override
  String get passwordShow => 'Show password';

  @override
  String get passwordHide => 'Hide password';

  @override
  String dietCopyMealsTargetBanner(String date) {
    return 'Copying into $date';
  }

  @override
  String get progressPhotosFeatureTitle => 'Progress photos';

  @override
  String get progressPhotosFeatureSubtitle => 'See your shape change over time';

  @override
  String get progressPhotosEmptyTitle => 'No photos yet';

  @override
  String get progressPhotosEmptyMessage => 'Add a photo now and then to see how your body changes over the weeks. Only you can see them.';

  @override
  String get progressPhotosAddAction => 'Add photo';

  @override
  String get progressPhotosSaveAction => 'Save photo';

  @override
  String get progressPhotosAddedMessage => 'Added to your timeline';

  @override
  String get progressPhotosDateLabel => 'Date';

  @override
  String get progressPhotosNoteLabel => 'Note (optional)';

  @override
  String get progressPhotosDeleteAction => 'Delete';

  @override
  String get progressPhotosCloseAction => 'Close';

  @override
  String get progressPhotosPickerTitle => 'Choose a photo';

  @override
  String get progressPhotosPoseLabel => 'Shot';

  @override
  String get progressPhotosPoseHint => 'Tag the angle so you can line up the same shot over time.';

  @override
  String get progressPhotosPoseFront => 'Front';

  @override
  String get progressPhotosPoseSide => 'Side';

  @override
  String get progressPhotosPoseBack => 'Back';

  @override
  String get progressPhotosPoseOther => 'Other';

  @override
  String get progressPhotosPrivacyTitle => 'Only you can see these';

  @override
  String get progressPhotosPrivacyMessage =>
      'Your photos are kept in a private folder locked to your account. No other user can open them, and they are never part of any shared catalog.';

  @override
  String get progressPhotosPrivacyHint => 'Private to you. Nobody else can see this photo.';

  @override
  String progressPhotosDayPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count shots', one: '1 shot', zero: 'No shots');
    return '$_temp0';
  }

  @override
  String get progressPhotosCompareTitle => 'Compare';

  @override
  String get progressPhotosComparePoseEmpty => 'Nothing to compare for this shot yet.';

  @override
  String get progressPhotosCompareBefore => 'Before';

  @override
  String get progressPhotosCompareAfter => 'After';

  @override
  String progressPhotosCompareDaysApart(int days) {
    String _temp0 = intl.Intl.pluralLogic(days, locale: localeName, other: '$days days apart', one: '1 day apart', zero: 'Same day');
    return '$_temp0';
  }

  @override
  String get trendsTitle => 'Trends';

  @override
  String get trendsFeatureTooltip => 'Trends';

  @override
  String get trendsAreasTitle => 'Area by area';

  @override
  String get trendsRingCaption => 'on track';

  @override
  String get trendsVerdictOnTrackTitle => 'You\'re on track';

  @override
  String get trendsVerdictMixedTitle => 'Mostly on track';

  @override
  String get trendsVerdictOffTrackTitle => 'Off track';

  @override
  String get trendsVerdictUnknownTitle => 'Nothing to judge yet';

  @override
  String get trendsVerdictUnknownMessage => 'Log a few days of food, water or sleep and this page will tell you how you\'re doing.';

  @override
  String trendsVerdictSummary(int onTrack, int total, int days) {
    return '$onTrack of $total goals on target over the last $days days';
  }

  @override
  String trendsChangeVsPrevious(String change, int days) {
    return '$change vs the previous $days days';
  }

  @override
  String get trendsNoComparison => 'No earlier data to compare with yet';

  @override
  String get trendsAdherenceMet => 'On target';

  @override
  String get trendsAdherenceClose => 'Close';

  @override
  String get trendsAdherenceOff => 'Off target';

  @override
  String get trendsMetricCalories => 'Calories per day';

  @override
  String get trendsMetricWater => 'Water per day';

  @override
  String get trendsMetricSleep => 'Sleep per night';

  @override
  String get trendsMetricVolume => 'Volume per session';

  @override
  String get trendsMetricBodyWeight => 'Weight';

  @override
  String get trendsEmptyTitle => 'No trends yet';

  @override
  String get trendsEmptyMessage => 'Track your food, water, sleep, workouts or weight for a few days and your story shows up here.';

  @override
  String get trendsEmptyAction => 'Start tracking';
}
