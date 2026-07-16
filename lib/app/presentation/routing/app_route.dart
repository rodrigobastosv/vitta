enum AppRoute {
  onboarding('/onboarding'),
  home('/'),
  diet('/diet'),
  dietCopy('/diet/copy'),
  dietHistory('/diet/history'),
  dietDay('/diet/history/day'),
  recipes('/diet/recipes'),
  recipeForm('/diet/recipes/new'),
  ingredientPicker('/diet/recipes/new/ingredient'),
  foodSearch('/diet/food-search'),
  customFood('/diet/food-search/custom-food'),
  water('/water'),
  waterHistory('/water/history'),
  sleep('/sleep'),
  sleepHistory('/sleep/history'),
  workout('/workout'),
  routines('/workout/routines'),
  routineForm('/workout/routines/new'),
  exerciseSearch('/workout/exercise-search'),
  exerciseDetail('/workout/exercise-search/detail'),
  profile('/profile'),
  editProfile('/profile/edit'),
  macroGoals('/profile/macro-goals'),
  settings('/settings'),
  signIn('/auth/sign-in'),
  signUp('/auth/sign-up');

  const AppRoute(this.path);

  final String path;
}
