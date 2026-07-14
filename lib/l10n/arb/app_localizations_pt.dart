// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Vitta';

  @override
  String get homeTagline => 'Seu companheiro de dieta e treino.';

  @override
  String get dietFeatureTitle => 'Dieta';

  @override
  String get dietFeatureSubtitle => 'Acompanhe refeições e atinja suas metas nutricionais';

  @override
  String get workoutFeatureTitle => 'Treino';

  @override
  String get workoutFeatureSubtitle => 'Planeje e registre seus treinos';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguageLabel => 'Idioma';

  @override
  String get languageSystemDefault => 'Padrão do sistema';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get themeSystemDefault => 'Padrão do sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get settingsUnitSystemLabel => 'Sistema de unidades';

  @override
  String get unitSystemMetric => 'Métrico (g/kg)';

  @override
  String get unitSystemImperial => 'Imperial (oz/lb)';

  @override
  String get comingSoonTitle => 'Em breve';

  @override
  String get dietComingSoonMessage => 'O acompanhamento de dieta está a caminho.';

  @override
  String get workoutComingSoonMessage => 'O acompanhamento de treino está a caminho.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get ok => 'OK';

  @override
  String progressLabel(String consumed, String goal, String unit) {
    return '$consumed / $goal $unit';
  }

  @override
  String dietCaloriesLabel(int calories) {
    return '$calories kcal hoje';
  }

  @override
  String dietCaloriesOfGoal(int goal) {
    return 'de $goal kcal';
  }

  @override
  String dietCaloriesLeft(int calories) {
    return 'faltam $calories kcal';
  }

  @override
  String dietCaloriesOver(int calories) {
    return '$calories kcal acima';
  }

  @override
  String get dietAddFood => 'Adicionar alimento';

  @override
  String get dietProteinLabel => 'Proteína';

  @override
  String get dietCarbsLabel => 'Carboidratos';

  @override
  String get dietFatLabel => 'Gordura';

  @override
  String dietLogSubtitle(int grams, int calories) {
    return '$grams g - $calories kcal';
  }

  @override
  String get dietDeleteLogTooltip => 'Remover';

  @override
  String get dietToday => 'Hoje';

  @override
  String get dietYesterday => 'Ontem';

  @override
  String get dietPreviousDayTooltip => 'Dia anterior';

  @override
  String get dietNextDayTooltip => 'Próximo dia';

  @override
  String get dietEmptyTitle => 'Nada registrado ainda';

  @override
  String get dietNotTodayEmptyTitle => 'Nada registrado nesse dia';

  @override
  String get dietEmptyMessage => 'Toque no botão + para adicionar o primeiro alimento do dia.';

  @override
  String get dietNotTodayEmptyMessage => 'Toque em + para adicionar um alimento nesse dia.';

  @override
  String get dietInvalidQuantity => 'Informe uma quantidade maior que zero.';

  @override
  String dietQuantityLabel(String unit) {
    return 'Quantidade ($unit)';
  }

  @override
  String get dietLogFoodAction => 'Adicionar ao dia';

  @override
  String dietFoodLoggedToast(String meal) {
    return 'Adicionado a $meal';
  }

  @override
  String get dietInvalidCustomFood => 'Preencha o nome e todos os macros com números válidos.';

  @override
  String get dietCustomFoodTitle => 'Cadastrar alimento';

  @override
  String get dietCustomFoodSubtitle => 'Ele entra no catálogo compartilhado com todo mundo.';

  @override
  String get dietFoodNameLabel => 'Nome';

  @override
  String get dietFoodNameHint => 'Iogurte grego, aveia em flocos, ...';

  @override
  String get dietBrandLabel => 'Marca (opcional)';

  @override
  String get dietBrandHint => 'Quem fabrica';

  @override
  String get dietAddPhotoAction => 'Adicionar foto';

  @override
  String get dietChangePhotoAction => 'Trocar foto';

  @override
  String get dietScanLabelHint => 'Fotografe a tabela nutricional e preenchemos os valores para você.';

  @override
  String get dietEnergyLabel => 'Calorias';

  @override
  String get dietKcalUnit => 'kcal';

  @override
  String get dietGramsUnit => 'g';

  @override
  String get dietEnergySplitTitle => 'Distribuição de energia';

  @override
  String dietMacroPercent(int percent) {
    return '$percent%';
  }

  @override
  String get dietFiberLabel => 'Fibra';

  @override
  String get dietMicronutrientsTitle => 'Vitaminas e minerais';

  @override
  String dietMicronutrientAmount(String amount, String unit) {
    return '$amount $unit';
  }

  @override
  String get nutrientVitaminA => 'Vitamina A';

  @override
  String get nutrientVitaminC => 'Vitamina C';

  @override
  String get nutrientVitaminD => 'Vitamina D';

  @override
  String get nutrientVitaminE => 'Vitamina E';

  @override
  String get nutrientVitaminK => 'Vitamina K';

  @override
  String get nutrientVitaminB1 => 'Vitamina B1';

  @override
  String get nutrientVitaminB2 => 'Vitamina B2';

  @override
  String get nutrientVitaminB3 => 'Vitamina B3';

  @override
  String get nutrientVitaminB6 => 'Vitamina B6';

  @override
  String get nutrientFolate => 'Folato';

  @override
  String get nutrientVitaminB12 => 'Vitamina B12';

  @override
  String get nutrientCalcium => 'Cálcio';

  @override
  String get nutrientIron => 'Ferro';

  @override
  String get nutrientMagnesium => 'Magnésio';

  @override
  String get nutrientPotassium => 'Potássio';

  @override
  String get nutrientSodium => 'Sódio';

  @override
  String get nutrientZinc => 'Zinco';

  @override
  String get dietTakePhotoAction => 'Tirar foto';

  @override
  String get dietChooseFromGalleryAction => 'Escolher da galeria';

  @override
  String get dietContinueAction => 'Continuar';

  @override
  String get dietScanLabelAction => 'Escanear tabela nutricional';

  @override
  String get dietNutritionScanNoData => 'Não foi possível ler a tabela nutricional. Preencha os valores manualmente.';

  @override
  String dietCaloriesPer100g(int calories) {
    return '$calories kcal / 100g';
  }

  @override
  String get dietFoodSearchTitle => 'Buscar alimentos';

  @override
  String get dietSearchFieldLabel => 'Buscar no Open Food Facts';

  @override
  String get dietSearchPrompt => 'Busque um alimento para registrá-lo.';

  @override
  String get dietSearchNoResults => 'Nenhum resultado. Tente outra busca ou cadastre manualmente.';

  @override
  String get dietNutritionPer100gTitle => 'Informação nutricional por 100g';

  @override
  String dietMacroGrams(String grams) {
    return '$grams g';
  }

  @override
  String get dietHistoryTitle => 'Histórico';

  @override
  String get dietHistoryTrendsTitle => 'Tendências';

  @override
  String dietWeekAverageShort(int calories) {
    return '$calories';
  }

  @override
  String dietWeekAverageTooltip(int calories, int days) {
    return 'Média semanal: $calories kcal em $days dias registrados';
  }

  @override
  String get dietWeekColumnLabel => 'Méd';

  @override
  String dietTrendRangeDays(int days) {
    return '${days}d';
  }

  @override
  String get dietCaloriesTrendTitle => 'Calorias';

  @override
  String get dietMacrosTrendTitle => 'Macros';

  @override
  String dietTrendAverageLabel(int calories) {
    return '$calories kcal/dia em média';
  }

  @override
  String dietTrendLoggedDays(int days, int total) {
    return '$days de $total dias registrados';
  }

  @override
  String get dietTrendEmptyMessage => 'Nada registrado nesse período ainda.';

  @override
  String get dietHistoryCalendarEmptyMessage => 'Nada registrado nesse mês.';

  @override
  String get dietDayDetailsEmptyMessage => 'Nada foi registrado nesse dia.';

  @override
  String get dietGoalLineLabel => 'Meta';

  @override
  String get dietMealSplitTitle => 'Calorias por refeição';

  @override
  String dietMealSplitAverage(int calories) {
    return '$calories kcal/dia';
  }

  @override
  String get mealTypeBreakfast => 'Café da manhã';

  @override
  String get mealTypeLunch => 'Almoço';

  @override
  String get mealTypeDinner => 'Jantar';

  @override
  String get mealTypeSnack => 'Lanche';

  @override
  String dietMealCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String dietMealMacros(int protein, int carbs, int fat, int fiber) {
    return 'P ${protein}g · C ${carbs}g · G ${fat}g · Fibra ${fiber}g';
  }

  @override
  String dietAddToMeal(String meal) {
    return 'Adicionar em $meal';
  }

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get saveAction => 'Salvar';

  @override
  String get waterFeatureTitle => 'Água';

  @override
  String get waterFeatureSubtitle => 'Acompanhe quanta água você bebe por dia';

  @override
  String get waterDeleteLogTooltip => 'Remover';

  @override
  String get waterEmptyTitle => 'Nada registrado ainda';

  @override
  String get waterEmptyMessage => 'Toque no botão + para registrar o primeiro copo d\'água.';

  @override
  String get waterQuickAddTitle => 'Adicionar água';

  @override
  String waterCustomAmountLabel(String unit) {
    return 'Quantidade personalizada ($unit)';
  }

  @override
  String get waterLogAction => 'Adicionar';

  @override
  String get waterInvalidAmount => 'Informe uma quantidade maior que zero.';

  @override
  String get waterGoalDialogTitle => 'Meta diária';

  @override
  String waterGoalLabel(String unit) {
    return 'Meta diária ($unit)';
  }

  @override
  String get sleepFeatureTitle => 'Sono';

  @override
  String get sleepFeatureSubtitle => 'Acompanhe seus padrões de sono';

  @override
  String get sleepEmptyTitle => 'Nada registrado ainda';

  @override
  String get sleepEmptyMessage => 'Toque no botão + para registrar sua primeira noite de sono.';

  @override
  String get sleepDeleteLogTooltip => 'Remover';

  @override
  String get sleepLogSheetTitle => 'Registrar sono';

  @override
  String get sleepBedTimeLabel => 'Horário de dormir';

  @override
  String get sleepWakeTimeLabel => 'Horário de acordar';

  @override
  String get sleepQualityLabel => 'Qualidade (opcional)';

  @override
  String get sleepInvalidRange => 'O horário de acordar deve ser depois do horário de dormir.';

  @override
  String get sleepLogAction => 'Registrar sono';

  @override
  String sleepDurationLabel(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao Vitta';

  @override
  String get onboardingWelcomeMessage =>
      'Acompanhe sua dieta, água, sono e treinos em um só lugar, e mantenha a consistência dia após dia.';

  @override
  String get onboardingAccountBenefitMessage =>
      'Crie uma conta gratuita para manter seus dados seguros e acessá-los em qualquer aparelho. Sem uma conta, seus dados ficam só neste dispositivo.';

  @override
  String get onboardingCreateAccountAction => 'Criar conta';

  @override
  String get onboardingContinueWithoutAccountAction => 'Continuar sem conta';

  @override
  String get settingsAuthLabel => 'Conta';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileSignInAction => 'Entrar ou criar conta';

  @override
  String get profileGuestTitle => 'Convidado';

  @override
  String get profileMacroGoalsSubtitle => 'Suas metas diárias de calorias e macros';

  @override
  String get profileSettingsSubtitle => 'Idioma, tema e unidades';

  @override
  String get macroGoalsTitle => 'Metas de macros';

  @override
  String get macroGoalsCalorieLabel => 'Meta de calorias (kcal)';

  @override
  String get macroGoalsProteinLabel => 'Meta de proteína (g)';

  @override
  String get macroGoalsCarbsLabel => 'Meta de carboidratos (g)';

  @override
  String get macroGoalsFatLabel => 'Meta de gordura (g)';

  @override
  String get macroGoalsFiberLabel => 'Meta de fibra (g)';

  @override
  String get macroGoalsInvalid => 'Preencha todas as metas com números válidos maiores que zero.';

  @override
  String get authAnonymousMessage =>
      'Seus dados ficam só neste dispositivo. Crie uma conta para mantê-los seguros e acessá-los em qualquer aparelho.';

  @override
  String authSignedInAsLabel(String email) {
    return 'Conectado como $email';
  }

  @override
  String get authCreateAction => 'Criar conta';

  @override
  String get authLoginAction => 'Entrar';

  @override
  String get authLogoutAction => 'Sair';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Senha';

  @override
  String get authSignUpAction => 'Criar conta';

  @override
  String get authSignInAction => 'Entrar';

  @override
  String get authInvalidEmailMessage => 'Informe um email válido.';

  @override
  String get authInvalidPasswordMessage => 'A senha deve ter pelo menos 6 caracteres.';
}
