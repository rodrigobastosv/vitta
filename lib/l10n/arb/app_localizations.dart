import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('pt')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Vitta'**
  String get appTitle;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Your companion for diet and training.'**
  String get homeTagline;

  /// No description provided for @dietFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get dietFeatureTitle;

  /// No description provided for @dietFeatureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track meals and reach your nutrition goals'**
  String get dietFeatureSubtitle;

  /// No description provided for @workoutFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutFeatureTitle;

  /// No description provided for @workoutFeatureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan and log your training sessions'**
  String get workoutFeatureSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeLabel;

  /// No description provided for @themeSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystemDefault;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsUnitSystemLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit system'**
  String get settingsUnitSystemLabel;

  /// No description provided for @unitSystemMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric (g/kg)'**
  String get unitSystemMetric;

  /// No description provided for @unitSystemImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial (oz/lb)'**
  String get unitSystemImperial;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonTitle;

  /// No description provided for @dietComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Diet tracking is on its way.'**
  String get dietComingSoonMessage;

  /// No description provided for @workoutComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Workout tracking is on its way.'**
  String get workoutComingSoonMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'{consumed} / {goal} {unit}'**
  String progressLabel(String consumed, String goal, String unit);

  /// No description provided for @dietCaloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal today'**
  String dietCaloriesLabel(int calories);

  /// No description provided for @dietCaloriesOfGoal.
  ///
  /// In en, this message translates to:
  /// **'of {goal} kcal'**
  String dietCaloriesOfGoal(int goal);

  /// No description provided for @dietCaloriesLeft.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal left'**
  String dietCaloriesLeft(int calories);

  /// No description provided for @dietCaloriesOver.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal over'**
  String dietCaloriesOver(int calories);

  /// No description provided for @dietAddFood.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get dietAddFood;

  /// No description provided for @dietProteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get dietProteinLabel;

  /// No description provided for @dietCarbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get dietCarbsLabel;

  /// No description provided for @dietFatLabel.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get dietFatLabel;

  /// No description provided for @dietLogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{grams} g - {calories} kcal'**
  String dietLogSubtitle(int grams, int calories);

  /// No description provided for @dietDeleteLogTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get dietDeleteLogTooltip;

  /// No description provided for @dietToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dietToday;

  /// No description provided for @dietYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dietYesterday;

  /// No description provided for @dietPreviousDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get dietPreviousDayTooltip;

  /// No description provided for @dietNextDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get dietNextDayTooltip;

  /// No description provided for @dietEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet'**
  String get dietEmptyTitle;

  /// No description provided for @dietNotTodayEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged on that day'**
  String get dietNotTodayEmptyTitle;

  /// No description provided for @dietEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add the first food of the day.'**
  String get dietEmptyMessage;

  /// No description provided for @dietNotTodayEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap + to log food for this day.'**
  String get dietNotTodayEmptyMessage;

  /// No description provided for @dietInvalidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity greater than zero.'**
  String get dietInvalidQuantity;

  /// No description provided for @dietQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity ({unit})'**
  String dietQuantityLabel(String unit);

  /// No description provided for @dietLogFoodAction.
  ///
  /// In en, this message translates to:
  /// **'Add to day'**
  String get dietLogFoodAction;

  /// No description provided for @dietFoodLoggedToast.
  ///
  /// In en, this message translates to:
  /// **'Added to {meal}'**
  String dietFoodLoggedToast(String meal);

  /// No description provided for @dietInvalidCustomFood.
  ///
  /// In en, this message translates to:
  /// **'Fill in the name and all macros with valid numbers.'**
  String get dietInvalidCustomFood;

  /// No description provided for @dietCustomFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a food'**
  String get dietCustomFoodTitle;

  /// No description provided for @dietCustomFoodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'It joins the shared catalog for everyone.'**
  String get dietCustomFoodSubtitle;

  /// No description provided for @dietFoodNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get dietFoodNameLabel;

  /// No description provided for @dietFoodNameHint.
  ///
  /// In en, this message translates to:
  /// **'Greek yogurt, rolled oats, ...'**
  String get dietFoodNameHint;

  /// No description provided for @dietBrandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand (optional)'**
  String get dietBrandLabel;

  /// No description provided for @dietBrandHint.
  ///
  /// In en, this message translates to:
  /// **'Who makes it'**
  String get dietBrandHint;

  /// No description provided for @addPhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhotoAction;

  /// No description provided for @changePhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhotoAction;

  /// No description provided for @dietScanLabelHint.
  ///
  /// In en, this message translates to:
  /// **'Snap the nutrition table and we fill in the values for you.'**
  String get dietScanLabelHint;

  /// No description provided for @dietEnergyLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get dietEnergyLabel;

  /// No description provided for @dietKcalUnit.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get dietKcalUnit;

  /// No description provided for @dietGramsUnit.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get dietGramsUnit;

  /// No description provided for @dietEnergySplitTitle.
  ///
  /// In en, this message translates to:
  /// **'Energy split'**
  String get dietEnergySplitTitle;

  /// No description provided for @dietMacroPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String dietMacroPercent(int percent);

  /// No description provided for @dietFiberLabel.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get dietFiberLabel;

  /// No description provided for @dietMicronutrientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vitamins & minerals'**
  String get dietMicronutrientsTitle;

  /// No description provided for @dietMicronutrientAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} {unit}'**
  String dietMicronutrientAmount(String amount, String unit);

  /// No description provided for @nutrientVitaminA.
  ///
  /// In en, this message translates to:
  /// **'Vitamin A'**
  String get nutrientVitaminA;

  /// No description provided for @nutrientVitaminC.
  ///
  /// In en, this message translates to:
  /// **'Vitamin C'**
  String get nutrientVitaminC;

  /// No description provided for @nutrientVitaminD.
  ///
  /// In en, this message translates to:
  /// **'Vitamin D'**
  String get nutrientVitaminD;

  /// No description provided for @nutrientVitaminE.
  ///
  /// In en, this message translates to:
  /// **'Vitamin E'**
  String get nutrientVitaminE;

  /// No description provided for @nutrientVitaminK.
  ///
  /// In en, this message translates to:
  /// **'Vitamin K'**
  String get nutrientVitaminK;

  /// No description provided for @nutrientVitaminB1.
  ///
  /// In en, this message translates to:
  /// **'Vitamin B1'**
  String get nutrientVitaminB1;

  /// No description provided for @nutrientVitaminB2.
  ///
  /// In en, this message translates to:
  /// **'Vitamin B2'**
  String get nutrientVitaminB2;

  /// No description provided for @nutrientVitaminB3.
  ///
  /// In en, this message translates to:
  /// **'Vitamin B3'**
  String get nutrientVitaminB3;

  /// No description provided for @nutrientVitaminB6.
  ///
  /// In en, this message translates to:
  /// **'Vitamin B6'**
  String get nutrientVitaminB6;

  /// No description provided for @nutrientFolate.
  ///
  /// In en, this message translates to:
  /// **'Folate'**
  String get nutrientFolate;

  /// No description provided for @nutrientVitaminB12.
  ///
  /// In en, this message translates to:
  /// **'Vitamin B12'**
  String get nutrientVitaminB12;

  /// No description provided for @nutrientCalcium.
  ///
  /// In en, this message translates to:
  /// **'Calcium'**
  String get nutrientCalcium;

  /// No description provided for @nutrientIron.
  ///
  /// In en, this message translates to:
  /// **'Iron'**
  String get nutrientIron;

  /// No description provided for @nutrientMagnesium.
  ///
  /// In en, this message translates to:
  /// **'Magnesium'**
  String get nutrientMagnesium;

  /// No description provided for @nutrientPotassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium'**
  String get nutrientPotassium;

  /// No description provided for @nutrientSodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get nutrientSodium;

  /// No description provided for @nutrientZinc.
  ///
  /// In en, this message translates to:
  /// **'Zinc'**
  String get nutrientZinc;

  /// No description provided for @takePhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhotoAction;

  /// No description provided for @chooseFromGalleryAction.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGalleryAction;

  /// No description provided for @dietContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get dietContinueAction;

  /// No description provided for @dietScanLabelAction.
  ///
  /// In en, this message translates to:
  /// **'Scan nutrition label'**
  String get dietScanLabelAction;

  /// No description provided for @dietNutritionScanNoData.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the nutrition label. Enter the values manually.'**
  String get dietNutritionScanNoData;

  /// No description provided for @dietCaloriesPer100g.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal / 100g'**
  String dietCaloriesPer100g(int calories);

  /// No description provided for @dietFoodSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search foods'**
  String get dietFoodSearchTitle;

  /// No description provided for @dietSearchFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Search Open Food Facts'**
  String get dietSearchFieldLabel;

  /// No description provided for @dietSearchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search for a food to log it.'**
  String get dietSearchPrompt;

  /// No description provided for @dietSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results. Try another search or add it manually.'**
  String get dietSearchNoResults;

  /// No description provided for @dietNutritionPer100gTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per 100g'**
  String get dietNutritionPer100gTitle;

  /// No description provided for @dietMacroGrams.
  ///
  /// In en, this message translates to:
  /// **'{grams} g'**
  String dietMacroGrams(String grams);

  /// No description provided for @dietHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get dietHistoryTitle;

  /// No description provided for @dietHistoryTrendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get dietHistoryTrendsTitle;

  /// No description provided for @dietWeekAverageShort.
  ///
  /// In en, this message translates to:
  /// **'{calories}'**
  String dietWeekAverageShort(int calories);

  /// No description provided for @dietWeekAverageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Weekly average: {calories} kcal over {days} logged days'**
  String dietWeekAverageTooltip(int calories, int days);

  /// No description provided for @dietWeekColumnLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get dietWeekColumnLabel;

  /// No description provided for @dietTrendRangeDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String dietTrendRangeDays(int days);

  /// No description provided for @dietCaloriesTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get dietCaloriesTrendTitle;

  /// No description provided for @dietMacrosTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Macros'**
  String get dietMacrosTrendTitle;

  /// No description provided for @dietTrendAverageLabel.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal/day average'**
  String dietTrendAverageLabel(int calories);

  /// No description provided for @dietTrendLoggedDays.
  ///
  /// In en, this message translates to:
  /// **'{days} of {total} days logged'**
  String dietTrendLoggedDays(int days, int total);

  /// No description provided for @dietTrendEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged in this period yet.'**
  String get dietTrendEmptyMessage;

  /// No description provided for @dietHistoryCalendarEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged this month.'**
  String get dietHistoryCalendarEmptyMessage;

  /// No description provided for @dietDayDetailsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Nothing was logged on this day.'**
  String get dietDayDetailsEmptyMessage;

  /// No description provided for @dietGoalLineLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get dietGoalLineLabel;

  /// No description provided for @dietMealSplitTitle.
  ///
  /// In en, this message translates to:
  /// **'Calories by meal'**
  String get dietMealSplitTitle;

  /// No description provided for @dietMealSplitAverage.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal/day'**
  String dietMealSplitAverage(int calories);

  /// No description provided for @dietRecipesTitle.
  ///
  /// In en, this message translates to:
  /// **'My recipes'**
  String get dietRecipesTitle;

  /// No description provided for @dietRecipesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get dietRecipesEmptyTitle;

  /// No description provided for @dietRecipesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap + to combine foods into a recipe you can log in one go.'**
  String get dietRecipesEmptyMessage;

  /// No description provided for @dietEditRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get dietEditRecipeTitle;

  /// No description provided for @dietCreateRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get dietCreateRecipeTitle;

  /// No description provided for @dietRecipeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipe name'**
  String get dietRecipeNameLabel;

  /// No description provided for @dietRecipeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Sunday lasagna, protein shake, ...'**
  String get dietRecipeNameHint;

  /// No description provided for @dietRecipeIngredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get dietRecipeIngredientsTitle;

  /// No description provided for @dietRecipeAddIngredientAction.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get dietRecipeAddIngredientAction;

  /// No description provided for @dietRecipeNoIngredientsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add the foods this recipe is made of.'**
  String get dietRecipeNoIngredientsMessage;

  /// No description provided for @dietRecipeIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Give the recipe a name and at least one ingredient.'**
  String get dietRecipeIncomplete;

  /// No description provided for @dietRecipeTotalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe totals'**
  String get dietRecipeTotalsTitle;

  /// No description provided for @dietRecipeTotalGrams.
  ///
  /// In en, this message translates to:
  /// **'{grams} g total'**
  String dietRecipeTotalGrams(int grams);

  /// No description provided for @dietRecipeSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save recipe'**
  String get dietRecipeSaveAction;

  /// No description provided for @dietRecipeSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Saved as a food you can log'**
  String get dietRecipeSavedToast;

  /// No description provided for @dietRecipeDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get dietRecipeDeleteTooltip;

  /// No description provided for @dietRecipeIngredientCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ingredients - {grams} g'**
  String dietRecipeIngredientCount(int count, int grams);

  /// No description provided for @dietPickIngredientTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a food'**
  String get dietPickIngredientTitle;

  /// No description provided for @dietRecipeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes are yours only and never show up in anyone else\'s search.'**
  String get dietRecipeSubtitle;

  /// No description provided for @dietRecipeLogHint.
  ///
  /// In en, this message translates to:
  /// **'Search it by name in Add food to log it on any day.'**
  String get dietRecipeLogHint;

  /// No description provided for @mealTypeBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealTypeBreakfast;

  /// No description provided for @mealTypeLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealTypeLunch;

  /// No description provided for @mealTypeDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealTypeDinner;

  /// No description provided for @mealTypeSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealTypeSnack;

  /// No description provided for @dietMealCalories.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal'**
  String dietMealCalories(int calories);

  /// No description provided for @dietMealMacros.
  ///
  /// In en, this message translates to:
  /// **'P {protein}g · C {carbs}g · F {fat}g · Fiber {fiber}g'**
  String dietMealMacros(int protein, int carbs, int fat, int fiber);

  /// No description provided for @dietAddToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add to {meal}'**
  String dietAddToMeal(String meal);

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @waterFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get waterFeatureTitle;

  /// No description provided for @waterFeatureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track how much water you drink each day'**
  String get waterFeatureSubtitle;

  /// No description provided for @waterDeleteLogTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get waterDeleteLogTooltip;

  /// No description provided for @waterEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet'**
  String get waterEmptyTitle;

  /// No description provided for @waterEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to log the first glass of water.'**
  String get waterEmptyMessage;

  /// No description provided for @waterQuickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add water'**
  String get waterQuickAddTitle;

  /// No description provided for @waterCustomAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom amount ({unit})'**
  String waterCustomAmountLabel(String unit);

  /// No description provided for @waterLogAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get waterLogAction;

  /// No description provided for @waterInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero.'**
  String get waterInvalidAmount;

  /// No description provided for @waterGoalDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get waterGoalDialogTitle;

  /// No description provided for @waterGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily goal ({unit})'**
  String waterGoalLabel(String unit);

  /// No description provided for @sleepFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepFeatureTitle;

  /// No description provided for @sleepFeatureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your sleep patterns'**
  String get sleepFeatureSubtitle;

  /// No description provided for @sleepEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet'**
  String get sleepEmptyTitle;

  /// No description provided for @sleepEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to log your first night of sleep.'**
  String get sleepEmptyMessage;

  /// No description provided for @sleepDeleteLogTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get sleepDeleteLogTooltip;

  /// No description provided for @sleepLogSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Log sleep'**
  String get sleepLogSheetTitle;

  /// No description provided for @sleepBedTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Bed time'**
  String get sleepBedTimeLabel;

  /// No description provided for @sleepWakeTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Wake time'**
  String get sleepWakeTimeLabel;

  /// No description provided for @sleepQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quality (optional)'**
  String get sleepQualityLabel;

  /// No description provided for @sleepInvalidRange.
  ///
  /// In en, this message translates to:
  /// **'Wake time must be after bed time.'**
  String get sleepInvalidRange;

  /// No description provided for @sleepLogAction.
  ///
  /// In en, this message translates to:
  /// **'Log sleep'**
  String get sleepLogAction;

  /// No description provided for @sleepDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String sleepDurationLabel(int hours, int minutes);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vitta'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Track your diet, water, sleep, and workouts in one place, and stay consistent day after day.'**
  String get onboardingWelcomeMessage;

  /// No description provided for @onboardingAccountBenefitMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a free account to keep your data safe and access it from any device. Without one, your data stays on this device only.'**
  String get onboardingAccountBenefitMessage;

  /// No description provided for @onboardingCreateAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get onboardingCreateAccountAction;

  /// No description provided for @onboardingContinueWithoutAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Continue without an account'**
  String get onboardingContinueWithoutAccountAction;

  /// No description provided for @settingsAuthLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAuthLabel;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create account'**
  String get profileSignInAction;

  /// No description provided for @profileGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuestTitle;

  /// No description provided for @profileMacroGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your daily calorie and macro targets'**
  String get profileMacroGoalsSubtitle;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, theme and units'**
  String get profileSettingsSubtitle;

  /// No description provided for @macroGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Macro goals'**
  String get macroGoalsTitle;

  /// No description provided for @macroGoalsCalorieLabel.
  ///
  /// In en, this message translates to:
  /// **'Calorie goal (kcal)'**
  String get macroGoalsCalorieLabel;

  /// No description provided for @macroGoalsProteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein goal (g)'**
  String get macroGoalsProteinLabel;

  /// No description provided for @macroGoalsCarbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs goal (g)'**
  String get macroGoalsCarbsLabel;

  /// No description provided for @macroGoalsFatLabel.
  ///
  /// In en, this message translates to:
  /// **'Fat goal (g)'**
  String get macroGoalsFatLabel;

  /// No description provided for @macroGoalsFiberLabel.
  ///
  /// In en, this message translates to:
  /// **'Fiber goal (g)'**
  String get macroGoalsFiberLabel;

  /// No description provided for @macroGoalsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Fill in all goals with valid numbers greater than zero.'**
  String get macroGoalsInvalid;

  /// No description provided for @authAnonymousMessage.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this device only. Create an account to keep it safe and access it from any device.'**
  String get authAnonymousMessage;

  /// No description provided for @authSignedInAsLabel.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String authSignedInAsLabel(String email);

  /// No description provided for @authCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAction;

  /// No description provided for @authLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginAction;

  /// No description provided for @authLogoutAction.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get authLogoutAction;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authSignUpAction.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUpAction;

  /// No description provided for @authSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authSignInAction;

  /// No description provided for @authInvalidEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authInvalidEmailMessage;

  /// No description provided for @authInvalidPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get authInvalidPasswordMessage;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
