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
  String get homeTagline => 'Seu companheiro para um dia mais saudável.';

  @override
  String get homeGreetingMorning => 'Bom dia';

  @override
  String get homeGreetingAfternoon => 'Boa tarde';

  @override
  String get homeGreetingEvening => 'Boa noite';

  @override
  String get reminderFeatureTitle => 'Lembretes';

  @override
  String get reminderFeatureSubtitle => 'Organize suas tarefas e lembretes';

  @override
  String get reminderTitle => 'Lembretes';

  @override
  String get reminderAddAction => 'Adicionar lembrete';

  @override
  String get reminderHistoryTitle => 'Histórico';

  @override
  String get reminderFilterAll => 'Todos';

  @override
  String get reminderFilterCompleted => 'Concluídos';

  @override
  String get reminderFilterActive => 'Ativos';

  @override
  String get reminderEmptyTitle => 'Nenhum lembrete';

  @override
  String get reminderEmptyMessage => 'Adicione um lembrete para este dia e ele estará esperando por você aqui.';

  @override
  String get reminderNewTitle => 'Novo lembrete';

  @override
  String get reminderEditTitle => 'Editar lembrete';

  @override
  String get reminderTitleLabel => 'Título';

  @override
  String get reminderTitleHint => 'Pagar a conta de luz, ...';

  @override
  String get reminderNotesLabel => 'Notas (opcional)';

  @override
  String get reminderDueDateLabel => 'Data';

  @override
  String get reminderRemindLabel => 'Lembrar-me';

  @override
  String get reminderRepeatLabel => 'Repetir';

  @override
  String get reminderRepeatNever => 'Nunca';

  @override
  String get reminderRepeatDaily => 'Diariamente';

  @override
  String get reminderRepeatWeekly => 'Semanalmente';

  @override
  String get reminderRepeatMonthly => 'Mensalmente';

  @override
  String get reminderDeleteTooltip => 'Remover';

  @override
  String get reminderCompleteAction => 'Concluir';

  @override
  String get reminderOverdueBadge => 'Atrasado';

  @override
  String get reminderPreviousDayTooltip => 'Dia anterior';

  @override
  String get reminderNextDayTooltip => 'Próximo dia';

  @override
  String get reminderToday => 'Hoje';

  @override
  String get reminderTomorrow => 'Amanhã';

  @override
  String get reminderYesterday => 'Ontem';

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
  String get previousMonth => 'Mês anterior';

  @override
  String get nextMonth => 'Próximo mês';

  @override
  String get increase => 'Aumentar';

  @override
  String get decrease => 'Diminuir';

  @override
  String get clearSearch => 'Limpar busca';

  @override
  String get dietHistoryEmptyTitle => 'Nenhuma refeição registrada';

  @override
  String get dietHistoryEmptyMessage =>
      'Registre alguns dias de refeições e seu calendário, tendências e divisão por refeição aparecerão aqui.';

  @override
  String get dietHistoryEmptyAction => 'Registrar refeição';

  @override
  String get waterHistoryEmptyTitle => 'Nenhuma água registrada';

  @override
  String get waterHistoryEmptyMessage => 'Acompanhe alguns dias e você verá como seu consumo evolui em relação à meta.';

  @override
  String get waterHistoryEmptyAction => 'Registrar água';

  @override
  String get sleepHistoryEmptyTitle => 'Nenhuma noite registrada';

  @override
  String get sleepHistoryEmptyMessage => 'Registre algumas noites e sua tendência de duração e divisão por qualidade aparecerão aqui.';

  @override
  String get sleepHistoryEmptyAction => 'Registrar sono';

  @override
  String get workoutHistoryEmptyTitle => 'Nenhum treino registrado';

  @override
  String get workoutHistoryEmptyMessage => 'Treine algumas sessões e você verá sua tendência de volume e quais músculos está trabalhando.';

  @override
  String get workoutHistoryEmptyAction => 'Começar um treino';

  @override
  String get reminderHistoryEmptyTitle => 'Nada neste mês';

  @override
  String get reminderHistoryEmptyMessage => 'Os lembretes que você criar aparecerão neste calendário, para você rever o que concluiu.';

  @override
  String get reminderHistoryEmptyAction => 'Criar lembrete';

  @override
  String get bodyWeightHistoryEmptyAction => 'Registrar peso';

  @override
  String get reminderFilterNoResultsTitle => 'Nada corresponde a este filtro';

  @override
  String get reminderFilterNoResultsMessage => 'Você tem lembretes neste dia, mas nenhum nesta visualização. Tente outro filtro.';

  @override
  String get homeTodayTitle => 'Hoje';

  @override
  String get homeAlsoTodayTitle => 'Também hoje';

  @override
  String get homeTrackTitle => 'Acompanhar';

  @override
  String homeMealsLogged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count refeições registradas',
      one: '1 refeição registrada',
      zero: 'Nada registrado ainda',
    );
    return '$_temp0';
  }

  @override
  String homeWaterLeft(String amount, String unit) {
    return 'faltam $amount $unit';
  }

  @override
  String get homeWaterDone => 'Meta atingida';

  @override
  String get homeNextReminder => 'Próximo lembrete';

  @override
  String get homeNoReminders => 'Nada para hoje';

  @override
  String homeWorkoutProgress(int done, int total) {
    return '$done de $total feitos';
  }

  @override
  String get homeNoWorkout => 'Nada registrado hoje';

  @override
  String get homeSleepLastNight => 'Noite passada';

  @override
  String get homeWeightLatest => 'Mais recente';

  @override
  String get homeNotTrackedYet => 'Ainda não acompanhado';

  @override
  String get onboardingFeaturesTitle => 'Muitas coisas, um app';

  @override
  String get onboardingGoalsTitle => 'Defina uma meta diária de calorias';

  @override
  String get onboardingGoalsMessage => 'Você pode mudar isso quando quiser, e nós dividimos entre proteínas, carboidratos e gorduras.';

  @override
  String get onboardingGoalsSkipAction => 'Pular por enquanto';

  @override
  String onboardingGoalsSuggestedFor(String objective) {
    return 'Sugerido para $objective';
  }

  @override
  String get onboardingBodyTitle => 'Conte sobre você';

  @override
  String get onboardingBodyMessage =>
      'Seu peso e sua altura permitem sugerir uma meta de calorias. Vamos salvar este peso como seu primeiro registro.';

  @override
  String get onboardingWeightLabel => 'Peso atual';

  @override
  String get onboardingHeightLabel => 'Altura';

  @override
  String get onboardingObjectiveTitle => 'Qual é o seu objetivo?';

  @override
  String get objectiveTitle => 'Seu objetivo';

  @override
  String get objectiveMessage =>
      'Seu objetivo define sua meta diária de calorias e como ela se divide em proteína, carboidrato e gordura. Mude sempre que seu treino mudar.';

  @override
  String get objectiveTargetTitle => 'Meta diária de calorias';

  @override
  String objectiveWeightFromLatest(String weight) {
    return 'A partir da sua última pesagem, $weight';
  }

  @override
  String objectiveWeightAssumed(String weight) {
    return 'Considerando $weight — registre um peso para uma meta feita sob medida';
  }

  @override
  String get objectiveOverwritesGoalsNote => 'Salvar substitui suas metas de macros. Você ainda pode ajustá-las na página de dieta.';

  @override
  String get objectiveSaveAction => 'Salvar objetivo';

  @override
  String get objectiveSavedTitle => 'Objetivo atualizado';

  @override
  String get objectiveSavedMessage => 'Sua meta de calorias e seus macros passam a segui-lo.';

  @override
  String get profileObjectiveSubtitle => 'Defina sua meta e recalcule seus alvos';

  @override
  String get onboardingObjectiveLoseWeight => 'Perder peso';

  @override
  String get onboardingObjectiveLoseWeightMessage => 'Comer abaixo da manutenção, mantendo a proteína alta';

  @override
  String get onboardingObjectiveMaintainWeight => 'Manter o peso';

  @override
  String get onboardingObjectiveMaintainWeightMessage => 'Ficar onde está, com uma divisão equilibrada';

  @override
  String get onboardingObjectiveGainMuscle => 'Ganhar músculo';

  @override
  String get onboardingObjectiveGainMuscleMessage => 'Comer um pouco acima da manutenção para construir';

  @override
  String get onboardingAccountTitle => 'Mantenha seus dados seguros';

  @override
  String get onboardingNextAction => 'Avançar';

  @override
  String get onboardingBackAction => 'Voltar';

  @override
  String get delete => 'Excluir';

  @override
  String get dietRecipeBadge => 'Receita';

  @override
  String get dietCommonFoodBadge => 'Comum';

  @override
  String dietQuantityUnits(String units) {
    return '$units un';
  }

  @override
  String dietQuantityGrams(int grams) {
    return '$grams g';
  }

  @override
  String get dietLogAgainAction => 'Registrar de novo';

  @override
  String get dietRecentlyLoggedTitle => 'Registrados recentemente';

  @override
  String get dietRecentSearchesTitle => 'Buscas recentes';

  @override
  String get dietRecentTabLabel => 'Recentes';

  @override
  String get dietRecentEmptyTitle => 'Nada registrado ainda';

  @override
  String get dietRecentEmptyMessage => 'Os alimentos que você registrar aparecerão aqui, prontos para adicionar de novo com um toque.';

  @override
  String get dietCopyMealsEmptyDayTitle => 'Nada registrado nesse dia';

  @override
  String get dietCopyMealsEmptyDayMessage => 'Escolha outro dia — este não tem refeições para copiar.';

  @override
  String get workoutRestTimerLabel => 'Descanso';

  @override
  String get workoutRestExtendAction => '+30s';

  @override
  String get workoutRestSkipAction => 'Pular';

  @override
  String get workoutNoSetsYet => 'Nenhuma série registrada ainda.';

  @override
  String get workoutInstructionsTitle => 'Como fazer';

  @override
  String get workoutRestShortenAction => 'Tirar 30 segundos';

  @override
  String get workoutRestConfigureAction => 'Duração do descanso';

  @override
  String get workoutRestSettingTitle => 'Descanso entre séries';

  @override
  String get workoutRestSettingHint => 'Usado toda vez que você registra uma série.';

  @override
  String get workoutLastSetPrefillNote => 'Preenchido com sua última série';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get ok => 'OK';

  @override
  String get errorTitle => 'Algo deu errado';

  @override
  String get warningTitle => 'Falta pouco';

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
  String get dietIntroTitle => 'Bem-vindo à Dieta';

  @override
  String get dietIntroSubtitle => 'Registre o que você come e veja suas calorias e macros se formarem dia após dia.';

  @override
  String get dietIntroLogTitle => 'Registre seus alimentos';

  @override
  String get dietIntroLogMessage =>
      'Busque em um catálogo compartilhado, escaneie um rótulo nutricional ou crie um alimento personalizado — e registre por peso ou por unidade.';

  @override
  String get dietIntroRecipeTitle => 'Monte receitas';

  @override
  String get dietIntroRecipeMessage =>
      'Salve as refeições que você come com frequência como receita e registre tudo de uma vez, em vez de adicionar cada ingrediente.';

  @override
  String get dietIntroTrackTitle => 'Acompanhe sua evolução';

  @override
  String get dietIntroTrackMessage =>
      'Cada registro entra nas suas calorias e macros do dia, em um calendário e em tendências ao longo do tempo.';

  @override
  String get dietIntroGoalsTitle => 'Defina uma meta que combina com você';

  @override
  String get dietIntroGoalsMessage =>
      'Suas metas de calorias e macros guiam tudo por aqui. Quer perder peso? Defina uma meta abaixo do que você gasta para criar um déficit — dá para ajustar quando quiser.';

  @override
  String get dietIntroSetGoalsAction => 'Definir minhas metas';

  @override
  String get dietIntroSkipAction => 'Pular por agora';

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
  String get dietEmptyMessage => 'Adicione o que você comeu e suas calorias e macros se preenchem conforme o dia passa.';

  @override
  String get dietNotTodayEmptyMessage => 'Nada foi registrado neste dia. Você ainda pode adicionar o que comeu.';

  @override
  String get dietInvalidQuantity => 'Informe uma quantidade maior que zero.';

  @override
  String dietQuantityLabel(String unit) {
    return 'Quantidade ($unit)';
  }

  @override
  String get dietUnitsUnit => 'un';

  @override
  String dietLogSubtitleUnits(String units, int calories) {
    return '$units un - $calories kcal';
  }

  @override
  String get dietGramsPerUnitLabel => 'Peso de uma unidade (g)';

  @override
  String get dietGramsPerUnitHint => 'Opcional. Preencha para registrar este alimento por unidade, como \"2 ovos\".';

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
  String get addPhotoAction => 'Adicionar foto';

  @override
  String get changePhotoAction => 'Trocar foto';

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
  String get takePhotoAction => 'Tirar foto';

  @override
  String get chooseFromGalleryAction => 'Escolher da galeria';

  @override
  String get dietScanLabelAction => 'Escanear tabela nutricional';

  @override
  String get dietNutritionScanNoDataTitle => 'Não deu para ler a tabela';

  @override
  String get dietNutritionScanNoData => 'Preencha os valores manualmente, ou tente outra foto.';

  @override
  String get dietNutritionScanningCaptionReading => 'Lendo o rótulo…';

  @override
  String get dietNutritionScanningCaptionExtracting => 'Extraindo as informações nutricionais…';

  @override
  String get mealScanTitle => 'Escanear refeição';

  @override
  String get mealScanIntroTitle => 'Fotografe sua refeição';

  @override
  String get mealScanIntroMessage => 'Tire uma foto do seu prato e identificamos os itens e estimamos os macros para você.';

  @override
  String get mealScanTakePhotoAction => 'Tirar uma foto';

  @override
  String get mealScanRetakeAction => 'Tentar outra foto';

  @override
  String get mealScanNoDataTitle => 'Nenhum alimento detectado';

  @override
  String get mealScanNoData =>
      'Não encontramos nenhum alimento nessa foto. Enquadre o prato inteiro com boa luz, chegue um pouco mais perto e tente de novo.';

  @override
  String get mealScanScanningCaptionLooking => 'Olhando para o seu prato…';

  @override
  String get mealScanScanningCaptionIdentifying => 'Identificando os alimentos…';

  @override
  String get mealScanScanningCaptionEstimating => 'Estimando as porções…';

  @override
  String get mealScanItemsTitle => 'Itens detectados';

  @override
  String mealScanFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count itens encontrados', one: '1 item encontrado');
    return '$_temp0';
  }

  @override
  String mealScanEstimatedTotal(int calories) {
    return '~$calories kcal estimadas';
  }

  @override
  String get mealScanPortionLabel => 'Porção';

  @override
  String get mealScanItemsSubtitle =>
      'Estes macros são estimativas — ajuste as quantidades, desmarque o que não quiser e adicione ao seu dia.';

  @override
  String get mealScanMealTypeTitle => 'Adicionar à refeição';

  @override
  String get mealScanLogAction => 'Adicionar ao diário';

  @override
  String get mealScanIncomplete => 'Escolha pelo menos um item com uma quantidade válida.';

  @override
  String get mealScanLoggedTitle => 'Refeição adicionada';

  @override
  String get mealScanLoggedMessage => 'Tudo o que você manteve já está no seu dia.';

  @override
  String dietCaloriesPer100g(int calories) {
    return '$calories kcal / 100g';
  }

  @override
  String get dietFoodSearchTitle => 'Adicionar alimento';

  @override
  String get dietFavoritesTitle => 'Favoritos';

  @override
  String get dietSearchTabLabel => 'Busca';

  @override
  String get dietClearRecentSearchesAction => 'Limpar';

  @override
  String get dietRemoveRecentSearchTooltip => 'Remover das buscas recentes';

  @override
  String get dietFavoritesEmptyTitle => 'Nenhum favorito ainda';

  @override
  String get dietFavoritesEmptyMessage => 'Toque no coração de qualquer alimento para deixá-lo aqui, a um toque de distância.';

  @override
  String get dietFavoriteFoodTooltip => 'Adicionar aos favoritos';

  @override
  String get dietUnfavoriteFoodTooltip => 'Remover dos favoritos';

  @override
  String get dietSearchFieldLabel => 'Buscar alimentos';

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
  String get waterHistoryTitle => 'Histórico';

  @override
  String get sleepHistoryTitle => 'Histórico';

  @override
  String get sleepDurationTrendTitle => 'Tempo dormido';

  @override
  String sleepTrendAverageLabel(String hours) {
    return 'média de $hours h/noite';
  }

  @override
  String get sleepTrendEmptyMessage => 'Nada registrado neste período ainda.';

  @override
  String sleepHoursShort(String hours) {
    return '${hours}h';
  }

  @override
  String sleepWeekAverageTooltip(String hours, int days) {
    return 'Média semanal: $hours h em $days noites registradas';
  }

  @override
  String get sleepQualitySplitTitle => 'Qualidade';

  @override
  String sleepRatedNights(int nights) {
    return '$nights noites avaliadas';
  }

  @override
  String get sleepQualityEmptyMessage => 'Nenhuma noite avaliada neste período ainda.';

  @override
  String sleepQualityStars(int rating) {
    return '$rating estrelas';
  }

  @override
  String get sleepGoalDialogTitle => 'Meta de sono por noite';

  @override
  String get sleepGoalLabel => 'Horas por noite';

  @override
  String get sleepGoalInvalid => 'Informe um número de horas maior que zero.';

  @override
  String get waterTrendTitle => 'Água';

  @override
  String waterTrendAverageLabel(int ml) {
    return 'média de $ml ml/dia';
  }

  @override
  String get waterTrendEmptyMessage => 'Nada registrado neste período ainda.';

  @override
  String waterWeekAverageShort(int ml) {
    return '$ml';
  }

  @override
  String waterWeekAverageTooltip(int ml, int days) {
    return 'Média semanal: $ml ml em $days dias registrados';
  }

  @override
  String trendRangeDays(int days) {
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
  String get dietCopyMealsTitle => 'Copiar refeições';

  @override
  String get dietCopyMealsPrompt => 'Escolha o dia de onde quer copiar as refeições.';

  @override
  String get dietCopyMealsNoSourceTitle => 'Nenhum dia escolhido';

  @override
  String get dietCopyMealsNoSourceMessage => 'Toque em um dia com alimentos registrados para escolher quais refeições copiar.';

  @override
  String get dietCopyMealsSelectionTitle => 'Refeições a copiar';

  @override
  String get dietCopyMealsAction => 'Copiar refeições';

  @override
  String dietCopyMealFoodCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count alimentos', one: '1 alimento', zero: 'Nenhum alimento');
    return '$_temp0';
  }

  @override
  String get dietMealsCopiedToastTitle => 'Refeições copiadas';

  @override
  String dietMealsCopiedToastMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count refeições adicionadas ao seu dia',
      one: '1 refeição adicionada ao seu dia',
      zero: 'Nenhuma refeição adicionada',
    );
    return '$_temp0';
  }

  @override
  String get dietMealSplitTitle => 'Calorias por refeição';

  @override
  String dietMealSplitAverage(int calories) {
    return '$calories kcal/dia';
  }

  @override
  String get dietRecipesTitle => 'Minhas receitas';

  @override
  String get dietRecipesEmptyTitle => 'Nenhuma receita ainda';

  @override
  String get dietRecipesEmptyMessage => 'Junte alimentos que você come sempre numa receita e registre tudo de uma vez.';

  @override
  String get dietEditRecipeTitle => 'Editar receita';

  @override
  String get dietCreateRecipeTitle => 'Nova receita';

  @override
  String get dietRecipeNameLabel => 'Nome da receita';

  @override
  String get dietRecipeNameHint => 'Lasanha de domingo, shake de proteína, ...';

  @override
  String get dietRecipeIngredientsTitle => 'Ingredientes';

  @override
  String get dietRecipeAddIngredientAction => 'Adicionar ingrediente';

  @override
  String get dietRecipeNoIngredientsMessage => 'Adicione os alimentos que compõem a receita.';

  @override
  String get dietRecipeIncomplete => 'Dê um nome à receita e adicione ao menos um ingrediente.';

  @override
  String get dietRecipeTotalsTitle => 'Totais da receita';

  @override
  String dietRecipeTotalGrams(int grams) {
    return '$grams g no total';
  }

  @override
  String get dietRecipeSaveAction => 'Salvar receita';

  @override
  String get dietRecipeSavedToast => 'Salva como um alimento que você pode registrar';

  @override
  String get dietRecipeDeleteTooltip => 'Remover';

  @override
  String get dietRecipeAddToMealAction => 'Adicionar à refeição';

  @override
  String dietRecipeIngredientCount(int count, int grams) {
    return '$count ingredientes - $grams g';
  }

  @override
  String get dietPickIngredientTitle => 'Escolher um alimento';

  @override
  String get dietRecipeSubtitle => 'Receitas são só suas e nunca aparecem na busca de outra pessoa.';

  @override
  String get dietRecipeLogHint =>
      'Toque em Adicionar à refeição para registrar a receita inteira, ou busque pelo nome em Adicionar alimento.';

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
  String get waterEmptyMessage => 'Use uma adição rápida acima para registrar o primeiro copo do dia.';

  @override
  String get bodyWeightFeatureTitle => 'Peso corporal';

  @override
  String get bodyWeightFeatureSubtitle => 'Acompanhe seu peso ao longo do tempo';

  @override
  String get bodyWeightHistoryTitle => 'Histórico de peso';

  @override
  String get bodyWeightCurrentTitle => 'Peso atual';

  @override
  String get bodyWeightEmptyTitle => 'Nenhum peso registrado';

  @override
  String get bodyWeightEmptyMessage => 'Registre seu peso para começar a acompanhar sua evolução.';

  @override
  String get bodyWeightLogAction => 'Registrar peso';

  @override
  String get bodyWeightDateLabel => 'Data';

  @override
  String bodyWeightValue(String value, String unit) {
    return '$value $unit';
  }

  @override
  String get bodyWeightRecentTitle => 'Registros recentes';

  @override
  String get bodyWeightTrendTitle => 'Tendência';

  @override
  String get bodyWeightStatMin => 'Mín';

  @override
  String get bodyWeightStatMax => 'Máx';

  @override
  String get bodyWeightStatAverage => 'Média';

  @override
  String get bodyWeightStatChange => 'Variação';

  @override
  String get bodyWeightHistoryEmptyTitle => 'Sem registros neste período';

  @override
  String get bodyWeightHistoryEmptyMessage => 'Registre seu peso para ver sua tendência.';

  @override
  String get workoutBodyweightPrefillNote => 'Preenchido com seu peso atual';

  @override
  String get waterQuickAddTitle => 'Adicionar água';

  @override
  String get waterQuickAddLabel => 'Adição rápida';

  @override
  String waterOfGoal(String goal, String unit) {
    return 'de $goal $unit';
  }

  @override
  String waterLeft(String amount, String unit) {
    return 'faltam $amount $unit';
  }

  @override
  String get waterGoalReached => 'Meta atingida!';

  @override
  String get waterGoalMetric => 'Meta';

  @override
  String get waterLogsMetric => 'Registros';

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
  String get sleepEmptyMessage => 'Registre uma noite e você começará a ver como seu descanso se compara à sua meta.';

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
  String sleepHoursOnly(int hours) {
    return '${hours}h';
  }

  @override
  String sleepMinutesOnly(int minutes) {
    return '${minutes}m';
  }

  @override
  String get sleepLastNightLabel => 'Última noite';

  @override
  String get sleepGoalReached => 'Meta atingida!';

  @override
  String sleepShort(String duration) {
    return 'faltam $duration';
  }

  @override
  String sleepOfGoal(String duration) {
    return 'de $duration';
  }

  @override
  String get sleepGoalMetric => 'Meta';

  @override
  String get sleepAverageMetric => 'Média';

  @override
  String get sleepNightsMetric => 'Noites';

  @override
  String get sleepSyncedTitle => 'Sono sincronizado';

  @override
  String get sleepSyncTooltip => 'Sincronizar do app de saúde';

  @override
  String get sleepSyncDebugTooltip => 'Inserir sono de exemplo (debug)';

  @override
  String sleepImportedMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count noites importadas',
      one: '1 noite importada',
      zero: 'Nada novo para importar',
    );
    return '$_temp0';
  }

  @override
  String get sleepHealthUnavailableMessage =>
      'Os dados de sono não estão disponíveis neste dispositivo. Configure o Health Connect (Android) ou a Apple Saúde (iOS) primeiro.';

  @override
  String get sleepHealthPermissionDeniedMessage => 'A permissão de sono foi negada. Conceda-a para importar suas noites.';

  @override
  String get sleepSourceHealth => 'Saúde';

  @override
  String get sleepSyncStatusTitle => 'App de saúde';

  @override
  String sleepLastSyncedLabel(String when) {
    return 'Sincronizado $when';
  }

  @override
  String get sleepSyncNowTooltip => 'Sincronizar agora';

  @override
  String get sleepLogDurationHint => 'Tempo dormindo';

  @override
  String get sleepQualityPoor => 'Ruim';

  @override
  String get sleepQualityFair => 'Razoável';

  @override
  String get sleepQualityGood => 'Boa';

  @override
  String get sleepQualityGreat => 'Ótima';

  @override
  String get sleepQualityExcellent => 'Excelente';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao Vitta';

  @override
  String get onboardingWelcomeMessage =>
      'Comida, treinos, água, sono, peso e lembretes — tudo em um só lugar, para manter a consistência dia após dia.';

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
  String get profileSettingsSubtitle => 'Idioma, tema e unidades';

  @override
  String get premiumTitle => 'Vitta Premium';

  @override
  String get premiumTagline => 'Registro com IA, sem digitar';

  @override
  String get premiumIntro =>
      'O escaneamento por foto usa IA para ler o alimento por você. Isso custa dinheiro de verdade, então fica no Premium — todo o resto do Vitta continua gratuito.';

  @override
  String get premiumFeaturesTitle => 'O que você libera';

  @override
  String get premiumFeatureMealScanTitle => 'Escanear foto da refeição';

  @override
  String get premiumFeatureMealScanSubtitle => 'Fotografe o prato e registre todos os itens de uma vez';

  @override
  String get premiumFeatureNutritionLabelScanTitle => 'Escanear rótulo nutricional';

  @override
  String get premiumFeatureNutritionLabelScanSubtitle => 'Aponte para o rótulo e os macros são preenchidos';

  @override
  String get premiumFreeTitle => 'Gratuito para sempre';

  @override
  String get premiumFreeMessage =>
      'Busca de alimentos, catálogo, receitas, água, sono, treinos, lembretes e todos os gráficos continuam gratuitos.';

  @override
  String get premiumSignUpPrompt => 'A assinatura fica vinculada à sua conta, então você precisa criar uma antes.';

  @override
  String get premiumSignUpAction => 'Criar uma conta';

  @override
  String get premiumActiveTitle => 'Premium ativo';

  @override
  String get premiumActiveMessage => 'Você tem acesso completo aos escaneamentos com IA. Obrigado por apoiar o Vitta.';

  @override
  String premiumRenewsOn(String date) {
    return 'Renova em $date';
  }

  @override
  String get premiumLockedBadge => 'Premium';

  @override
  String get premiumTermsAction => 'Termos de Uso';

  @override
  String get premiumPrivacyAction => 'Política de Privacidade';

  @override
  String get premiumAutoRenewalDisclosure =>
      'A cobrança é feita na sua conta do Apple ID ao confirmar a compra. A assinatura é renovada automaticamente, a menos que seja cancelada com pelo menos 24 horas de antecedência do fim do período atual. Você pode gerenciar ou cancelar quando quiser nos ajustes da sua conta da App Store.';

  @override
  String get premiumLinkFailed => 'Não foi possível abrir o link.';

  @override
  String get premiumSubscribeAction => 'Assinar o Premium';

  @override
  String get premiumRestoreAction => 'Restaurar compras';

  @override
  String get premiumUnavailable => 'As assinaturas não estão disponíveis agora. Tente mais tarde.';

  @override
  String get premiumPurchaseFailed => 'Não foi possível concluir a compra.';

  @override
  String get premiumRestoredTitle => 'Bem-vindo de volta';

  @override
  String get premiumRestoredMessage => 'Sua assinatura está ativa novamente.';

  @override
  String get premiumNothingToRestore => 'Nenhuma assinatura anterior foi encontrada para este Apple ID.';

  @override
  String get premiumPurchasedTitle => 'Tudo pronto';

  @override
  String get premiumPurchasedMessage => 'Os escaneamentos com IA estão liberados.';

  @override
  String get premiumRequiredTitle => 'Premium necessário';

  @override
  String get premiumRequiredMessage => 'Sua assinatura não está ativa, então o escaneamento não foi feito.';

  @override
  String get profilePremiumTitle => 'Premium';

  @override
  String get profilePremiumSubtitleActive => 'Assinatura ativa';

  @override
  String get profilePremiumSubtitleFree => 'Libere os escaneamentos com IA';

  @override
  String get profileDeleteAccountTitle => 'Excluir conta';

  @override
  String get profileDeleteAccountSubtitle => 'Apagar permanentemente sua conta e seus dados';

  @override
  String get deleteAccountDialogTitle => 'Excluir conta?';

  @override
  String get deleteAccountDialogMessage =>
      'Isso exclui permanentemente sua conta e todos os seus dados — refeições, treinos, peso, água, sono e tudo mais. Não é possível desfazer.';

  @override
  String get deleteAccountConfirmAction => 'Excluir conta';

  @override
  String get profileAccountDeleted => 'Conta excluída';

  @override
  String get profileAccountDeletedMessage => 'Sua conta e todos os seus dados foram excluídos permanentemente.';

  @override
  String get macroGoalsTitle => 'Metas de macros';

  @override
  String get macroGoalsEditTooltip => 'Editar metas';

  @override
  String get macroGoalsCalorieTargetTitle => 'Meta de calorias';

  @override
  String get macroGoalsCalorieTargetHint => 'Calculada a partir dos seus macros';

  @override
  String get macroGoalsCalorieMinLabel => 'Mín';

  @override
  String get macroGoalsCalorieMaxLabel => 'Máx';

  @override
  String macroGoalsKcal(int value) {
    return '$value kcal';
  }

  @override
  String get macroGoalsModalityTitle => 'Modalidade da dieta';

  @override
  String get macroGoalsModalityHint => 'Escolha um preset e ajuste abaixo';

  @override
  String get macroGoalsModalityCustom => 'Personalizada';

  @override
  String get dietModalityBalanced => 'Balanceada';

  @override
  String get dietModalityHighProtein => 'Rica em proteína';

  @override
  String get dietModalityLowFat => 'Baixa gordura';

  @override
  String get dietModalityLowCarb => 'Baixa em carboidratos';

  @override
  String get dietModalityKeto => 'Cetogênica';

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

  @override
  String get authDisplayNameLabel => 'Nome de exibição';

  @override
  String get authAvatarLabel => 'Avatar';

  @override
  String get authHasAccountAction => 'Já tem uma conta? Entrar';

  @override
  String get authNoAccountAction => 'Ainda não tem conta? Criar';

  @override
  String get authPickAvatarAction => 'Escolher um avatar';

  @override
  String get authRemoveAvatarAction => 'Remover';

  @override
  String get signInTitle => 'Entrar';

  @override
  String get signUpTitle => 'Criar conta';

  @override
  String get profileAvatarPickerTitle => 'Escolha um avatar';

  @override
  String get profileEditAction => 'Editar perfil';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get editProfileSaveAction => 'Salvar';

  @override
  String get profileUpdatedToast => 'Perfil atualizado';

  @override
  String get profileUpdatedToastMessage => 'Seu perfil está atualizado.';

  @override
  String get muscleGroupAbdominals => 'Abdômen';

  @override
  String get muscleGroupAbductors => 'Abdutores';

  @override
  String get muscleGroupAdductors => 'Adutores';

  @override
  String get muscleGroupBiceps => 'Bíceps';

  @override
  String get muscleGroupCalves => 'Panturrilhas';

  @override
  String get muscleGroupChest => 'Peito';

  @override
  String get muscleGroupForearms => 'Antebraços';

  @override
  String get muscleGroupGlutes => 'Glúteos';

  @override
  String get muscleGroupHamstrings => 'Posteriores de coxa';

  @override
  String get muscleGroupLats => 'Dorsais';

  @override
  String get muscleGroupLowerBack => 'Lombar';

  @override
  String get muscleGroupMiddleBack => 'Meio das costas';

  @override
  String get muscleGroupNeck => 'Pescoço';

  @override
  String get muscleGroupQuadriceps => 'Quadríceps';

  @override
  String get muscleGroupShoulders => 'Ombros';

  @override
  String get muscleGroupTraps => 'Trapézio';

  @override
  String get muscleGroupTriceps => 'Tríceps';

  @override
  String get bodyRegionChest => 'Peito';

  @override
  String get bodyRegionBack => 'Costas';

  @override
  String get bodyRegionShoulders => 'Ombros';

  @override
  String get bodyRegionArms => 'Braços';

  @override
  String get bodyRegionCore => 'Core';

  @override
  String get bodyRegionLegs => 'Pernas';

  @override
  String get exerciseCategoryStrength => 'Força';

  @override
  String get exerciseCategoryCardio => 'Cardio';

  @override
  String get exerciseCategoryStretching => 'Alongamento';

  @override
  String get exerciseCategoryPlyometrics => 'Pliometria';

  @override
  String get exerciseCategoryPowerlifting => 'Powerlifting';

  @override
  String get exerciseCategoryOlympicWeightlifting => 'Levantamento olímpico';

  @override
  String get exerciseCategoryStrongman => 'Strongman';

  @override
  String get exerciseLevelBeginner => 'Iniciante';

  @override
  String get exerciseLevelIntermediate => 'Intermediário';

  @override
  String get exerciseLevelExpert => 'Avançado';

  @override
  String get equipmentBarbell => 'Barra';

  @override
  String get equipmentDumbbell => 'Halteres';

  @override
  String get equipmentKettlebells => 'Kettlebell';

  @override
  String get equipmentCable => 'Cabo';

  @override
  String get equipmentMachine => 'Máquina';

  @override
  String get equipmentBands => 'Elásticos';

  @override
  String get equipmentBodyOnly => 'Peso corporal';

  @override
  String get equipmentExerciseBall => 'Bola suíça';

  @override
  String get equipmentMedicineBall => 'Medicine ball';

  @override
  String get equipmentFoamRoll => 'Rolo de espuma';

  @override
  String get equipmentEzCurlBar => 'Barra W';

  @override
  String get equipmentOther => 'Outro';

  @override
  String get workoutTodayTitle => 'Hoje';

  @override
  String get workoutPreviousDayTooltip => 'Dia anterior';

  @override
  String get workoutNextDayTooltip => 'Próximo dia';

  @override
  String get workoutAddExercise => 'Adicionar exercício';

  @override
  String get workoutEmptyTitle => 'Nenhum treino registrado';

  @override
  String get workoutEmptyMessage => 'Adicione um exercício para começar o treino de hoje.';

  @override
  String get workoutIntroTitle => 'Bem-vindo ao Treino';

  @override
  String get workoutIntroSubtitle => 'Registre seus treinos, acompanhe seus números subirem e deixe o app planejar o próximo.';

  @override
  String get workoutIntroLogTitle => 'Registre cada série';

  @override
  String get workoutIntroLogMessage =>
      'Adicione exercícios e anote repetições e carga — as séries vêm preenchidas da última vez, é só ajustar.';

  @override
  String get workoutIntroProgressTitle => 'Veja sua evolução';

  @override
  String get workoutIntroProgressMessage =>
      'Volume, histórico e progressão por exercício são montados automaticamente conforme você treina.';

  @override
  String get workoutIntroRoutineTitle => 'O que é uma rotina?';

  @override
  String get workoutIntroRoutineMessage =>
      'Uma rotina é uma lista nomeada e ordenada de exercícios — como \"Empurrar — peito e tríceps\". Suas rotinas formam um ciclo, e o app sugere qual treinar a seguir, então você nunca fica sem saber o que fazer hoje.';

  @override
  String get workoutIntroCreateRoutineAction => 'Criar minha primeira rotina';

  @override
  String get workoutIntroSkipAction => 'Pular por agora';

  @override
  String get workoutVolumeLabel => 'Volume';

  @override
  String get workoutSetsLabel => 'Séries';

  @override
  String get workoutRepsLabel => 'Repetições';

  @override
  String get workoutExercisesLabel => 'exercícios';

  @override
  String workoutExercisesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Faltam $count', one: 'Falta 1', zero: 'Tudo feito');
    return '$_temp0';
  }

  @override
  String workoutLoadLabel(String unit) {
    return 'Carga ($unit)';
  }

  @override
  String get workoutLoadHelper => 'Deixe a carga vazia para uma série de peso corporal.';

  @override
  String get workoutTotalRepsLabel => 'Total de repetições';

  @override
  String get workoutHeaviestLabel => 'Maior carga';

  @override
  String get workoutAddSet => 'Adicionar série';

  @override
  String get workoutEditSet => 'Editar série';

  @override
  String get workoutLogSetAction => 'Salvar série';

  @override
  String get workoutEffortLabel => 'Esforço';

  @override
  String get workoutLogEffortAction => 'Registrar esforço';

  @override
  String get workoutEditEffortAction => 'Editar esforço';

  @override
  String get workoutSaveEffortAction => 'Salvar esforço';

  @override
  String get workoutNoEffortMessage => 'Nenhum esforço registrado ainda.';

  @override
  String get workoutCompleteNeedsEffortTooltip => 'Registre o esforço antes de concluir este exercício';

  @override
  String get workoutDeleteSetTooltip => 'Remover série';

  @override
  String get workoutDeleteExercise => 'Remover exercício';

  @override
  String get workoutDeleteWorkout => 'Excluir treino';

  @override
  String get workoutDeleteWorkoutMessage => 'Isso exclui todos os exercícios e séries registrados neste dia.';

  @override
  String get workoutNoSetsMessage => 'Nenhuma série ainda.';

  @override
  String get workoutBodyweightLabel => 'Peso corporal';

  @override
  String get workoutInvalidRepsMessage => 'Informe quantas repetições você fez.';

  @override
  String get workoutInvalidLoadMessage => 'Informe uma carga válida, ou deixe vazio para peso corporal.';

  @override
  String workoutSetSummary(int reps) {
    return '$reps repetições';
  }

  @override
  String workoutLastTimeLabel(String summary) {
    return 'Última vez: $summary';
  }

  @override
  String workoutSetsSummaryUniform(int sets, int reps) {
    return '$sets×$reps';
  }

  @override
  String workoutSetsSummaryMixed(int sets) {
    String _temp0 = intl.Intl.pluralLogic(sets, locale: localeName, other: '$sets séries', one: '1 série', zero: 'nenhuma série');
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
  String get workoutDurationLabel => 'Duração';

  @override
  String get workoutDurationMinutesLabel => 'Min';

  @override
  String get workoutDurationSecondsLabel => 'Seg';

  @override
  String workoutDistanceLabel(String unit) {
    return 'Distância ($unit)';
  }

  @override
  String get workoutDistanceOptionalHelper => 'O tempo é obrigatório; a distância é opcional.';

  @override
  String get workoutInvalidDurationMessage => 'Informe quanto tempo durou.';

  @override
  String get workoutInvalidDistanceMessage => 'Informe uma distância válida, ou deixe em branco.';

  @override
  String get workoutTimeLabel => 'Tempo';

  @override
  String get workoutDistanceMetricLabel => 'Distância';

  @override
  String get workoutCardioTrendTitle => 'Tempo de cardio';

  @override
  String get workoutCardioTrendEmptyMessage => 'Nenhum cardio registrado neste período ainda.';

  @override
  String get workoutCardioDurationLegend => 'Duração';

  @override
  String workoutCardioTrendAverage(int minutes) {
    return '$minutes min/dia méd';
  }

  @override
  String get exerciseSearchTitle => 'Exercícios';

  @override
  String get exerciseSearchHint => 'Buscar exercícios';

  @override
  String get exerciseSearchEmptyTitle => 'Nenhum exercício encontrado';

  @override
  String get exerciseSearchEmptyMessage => 'Tente outro termo ou remova o filtro de músculo.';

  @override
  String get exerciseSearchAllFilter => 'Todos';

  @override
  String get exerciseDetailInstructionsTitle => 'Como fazer';

  @override
  String get exerciseDetailPrimaryMusclesTitle => 'Músculos principais';

  @override
  String get exerciseDetailSecondaryMusclesTitle => 'Também trabalha';

  @override
  String get exerciseDetailNoInstructionsMessage => 'Este exercício ainda não tem instruções.';

  @override
  String get exerciseDetailAddAction => 'Adicionar ao treino';

  @override
  String get workoutRoutinesTitle => 'Rotinas';

  @override
  String get workoutRoutinesTooltip => 'Rotinas';

  @override
  String get workoutRoutinesEmptyTitle => 'Nenhuma rotina ainda';

  @override
  String get workoutRoutinesEmptyMessage => 'Monte seu ABC e o app diz qual é o próximo treino.';

  @override
  String get workoutRoutineNewAction => 'Nova rotina';

  @override
  String get workoutRoutineNameLabel => 'Nome da rotina';

  @override
  String get workoutRoutineNameHint => 'Treino A — Peito e tríceps';

  @override
  String get workoutRoutineExercisesTitle => 'Exercícios';

  @override
  String get workoutRoutineAddExerciseAction => 'Adicionar exercício';

  @override
  String get workoutRoutineSaveAction => 'Salvar rotina';

  @override
  String get workoutRoutineDeleteTooltip => 'Remover';

  @override
  String get workoutRoutineRemoveExerciseTooltip => 'Remover da rotina';

  @override
  String get workoutRoutineIncompleteMessage => 'Dê um nome à rotina e adicione pelo menos um exercício.';

  @override
  String workoutRoutineExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercícios',
      one: '1 exercício',
      zero: 'Nenhum exercício',
    );
    return '$_temp0';
  }

  @override
  String get workoutNextRoutineLabel => 'Próximo';

  @override
  String workoutStartRoutineAction(String name) {
    return 'Iniciar $name';
  }

  @override
  String get workoutRoutineLastTrainedNever => 'Ainda não treinado';

  @override
  String workoutFromRoutineLabel(String name) {
    return 'De $name';
  }

  @override
  String get workoutStartRoutineHint => 'As séries vêm preenchidas com seu último treino — ajuste o que mudou.';

  @override
  String get reorderHandleLabel => 'Reordenar';

  @override
  String get workoutRepeatSetAction => 'Repetir série';

  @override
  String get workoutRepeatSetTooltip => 'Repetir a última série';

  @override
  String get workoutCompleteExerciseAction => 'Concluir';

  @override
  String get workoutReopenExerciseAction => 'Reabrir';

  @override
  String workoutCompletedSummary(int sets) {
    String _temp0 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets séries feitas',
      one: '1 série feita',
      zero: 'Nenhuma série',
    );
    return '$_temp0';
  }

  @override
  String get workoutSummaryTitle => 'Resumo do treino';

  @override
  String get workoutSummaryHeadline => 'Treino concluído';

  @override
  String get workoutSummaryDoneAction => 'Concluir';

  @override
  String get workoutSummaryProgressTitle => 'Comparado à última vez';

  @override
  String get workoutSummaryProgressFirst => 'Primeira vez';

  @override
  String get workoutSummaryProgressFlat => 'Igual à última vez';

  @override
  String workoutSummaryProgressUpVolume(String delta, String unit) {
    return '+$delta $unit de volume';
  }

  @override
  String workoutSummaryProgressDownVolume(String delta, String unit) {
    return '−$delta $unit de volume';
  }

  @override
  String workoutSummaryProgressUpDuration(int minutes) {
    return '$minutes min a mais';
  }

  @override
  String workoutSummaryProgressDownDuration(int minutes) {
    return '$minutes min a menos';
  }

  @override
  String workoutSummaryProgressHeavier(String delta, String unit) {
    return 'Série mais pesada subiu $delta $unit';
  }

  @override
  String workoutSummaryImprovedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercícios subiram',
      one: '1 exercício subiu',
      zero: 'Nada subiu desta vez',
    );
    return '$_temp0';
  }

  @override
  String get workoutSummaryExercisesTitle => 'O que você fez';

  @override
  String get workoutFinishedTitle => 'Treino concluído';

  @override
  String get workoutFinishedMessage => 'Todos os exercícios estão feitos. Mandou bem — até o próximo treino.';

  @override
  String get workoutSummaryViewAction => 'Ver resumo';

  @override
  String get workoutFinishedCaloriesLabel => 'Gasto estimado';

  @override
  String workoutFinishedCaloriesValue(int calories) {
    return '~$calories kcal';
  }

  @override
  String get workoutFinishedCaloriesHint => 'Calculado a partir do seu peso, do que você treinou e do tempo que isso leva.';

  @override
  String get workoutFinishedCaloriesNoWeightHint => 'Uma estimativa grosseira — registre seu peso para chegar mais perto.';

  @override
  String get workoutCompleteNeedsSetTooltip => 'Registre uma série antes de concluir este exercício';

  @override
  String get workoutProgressionTitle => 'Progressão';

  @override
  String get workoutProgressionEmptyTitle => 'Ainda sem histórico';

  @override
  String get workoutProgressionEmptyMessage => 'Registre este exercício em alguns treinos e a progressão de carga aparece aqui.';

  @override
  String get workoutProgressionRecordsTitle => 'Recordes pessoais';

  @override
  String get workoutProgressionBestE1rmLabel => 'Melhor 1RM est.';

  @override
  String get workoutProgressionHeaviestLabel => 'Maior carga';

  @override
  String get workoutProgressionE1rmTitle => '1RM estimado';

  @override
  String get workoutProgressionHeaviestTitle => 'Maior carga';

  @override
  String workoutProgressionSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Últimas $count sessões',
      one: 'Última sessão',
      zero: 'Nenhuma sessão',
    );
    return '$_temp0';
  }

  @override
  String get workoutProgressionListTitle => 'Progressão';

  @override
  String get workoutProgressionListEmptyTitle => 'Nenhum exercício registrado ainda';

  @override
  String get workoutProgressionListEmptyMessage =>
      'Registre alguns treinos e os exercícios que você fez aparecem aqui para acompanhar a progressão.';

  @override
  String get workoutHistoryTitle => 'Histórico';

  @override
  String workoutHistoryWeekSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count treinos', one: '1 treino', zero: 'Nenhum treino');
    return '$_temp0';
  }

  @override
  String get workoutVolumeTrendTitle => 'Volume por sessão';

  @override
  String workoutVolumeAverageLabel(String value) {
    return '$value méd.';
  }

  @override
  String workoutHistoryVolumeSummary(int sessions, int sets) {
    String _temp0 = intl.Intl.pluralLogic(
      sessions,
      locale: localeName,
      other: '$sessions sessões',
      one: '1 sessão',
      zero: 'Nenhuma sessão',
    );
    String _temp1 = intl.Intl.pluralLogic(sets, locale: localeName, other: '$sets séries', one: '1 série', zero: 'nenhuma série');
    return '$_temp0 · $_temp1';
  }

  @override
  String get workoutMuscleSplitTitle => 'Volume por grupo muscular';

  @override
  String get workoutMuscleSplitEmptyMessage =>
      'Nenhuma carga levantada neste período. Séries com peso mostram aqui a divisão por grupo muscular.';

  @override
  String get premiumCancelAnytime => 'Cancele quando quiser nos ajustes da App Store.';

  @override
  String get premiumOfferRetryAction => 'Tentar de novo';

  @override
  String get premiumPeriodWeekly => 'por semana';

  @override
  String get premiumPeriodMonthly => 'por mês';

  @override
  String get premiumPeriodTwoMonth => 'a cada 2 meses';

  @override
  String get premiumPeriodThreeMonth => 'a cada 3 meses';

  @override
  String get premiumPeriodSixMonth => 'a cada 6 meses';

  @override
  String get premiumPeriodAnnual => 'por ano';

  @override
  String get premiumPeriodLifetime => 'pagamento único';

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
    return '$date\nP ${protein}g · C ${carbs}g · G ${fat}g';
  }

  @override
  String get dietDayReadOnlyBadge => 'Somente leitura';

  @override
  String get workoutProgressionRecordLegend => 'Recorde pessoal';

  @override
  String get passwordShow => 'Mostrar senha';

  @override
  String get passwordHide => 'Ocultar senha';

  @override
  String dietCopyMealsTargetBanner(String date) {
    return 'Copiando para $date';
  }

  @override
  String get progressPhotosFeatureTitle => 'Fotos de progresso';

  @override
  String get progressPhotosFeatureSubtitle => 'Veja seu corpo mudar ao longo do tempo';

  @override
  String get progressPhotosEmptyTitle => 'Nenhuma foto ainda';

  @override
  String get progressPhotosEmptyMessage =>
      'Adicione uma foto de vez em quando para ver seu corpo mudar ao longo das semanas. Só você pode vê-las.';

  @override
  String get progressPhotosAddAction => 'Adicionar foto';

  @override
  String get progressPhotosSaveAction => 'Salvar foto';

  @override
  String get progressPhotosAddedMessage => 'Adicionada à sua linha do tempo';

  @override
  String get progressPhotosDateLabel => 'Data';

  @override
  String get progressPhotosNoteLabel => 'Observação (opcional)';

  @override
  String get progressPhotosDeleteAction => 'Excluir';

  @override
  String get progressPhotosCloseAction => 'Fechar';

  @override
  String get progressPhotosPickerTitle => 'Escolha uma foto';

  @override
  String get progressPhotosPoseLabel => 'Ângulo';

  @override
  String get progressPhotosPoseHint => 'Marque o ângulo para comparar sempre a mesma foto ao longo do tempo.';

  @override
  String get progressPhotosPoseFront => 'Frente';

  @override
  String get progressPhotosPoseSide => 'Lado';

  @override
  String get progressPhotosPoseBack => 'Costas';

  @override
  String get progressPhotosPoseOther => 'Outro';

  @override
  String get progressPhotosPrivacyTitle => 'Só você vê essas fotos';

  @override
  String get progressPhotosPrivacyMessage =>
      'Suas fotos ficam em uma pasta privada, ligada à sua conta. Nenhum outro usuário consegue abri-las, e elas nunca entram em nenhum catálogo compartilhado.';

  @override
  String get progressPhotosPrivacyHint => 'Privada: ninguém além de você vê esta foto.';

  @override
  String progressPhotosDayPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count fotos', one: '1 foto', zero: 'Nenhuma foto');
    return '$_temp0';
  }

  @override
  String get progressPhotosCompareTitle => 'Comparar';

  @override
  String get progressPhotosComparePoseEmpty => 'Ainda não há o que comparar neste ângulo.';

  @override
  String get progressPhotosCompareBefore => 'Antes';

  @override
  String get progressPhotosCompareAfter => 'Depois';

  @override
  String progressPhotosCompareDaysApart(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias de diferença',
      one: '1 dia de diferença',
      zero: 'No mesmo dia',
    );
    return '$_temp0';
  }
}
