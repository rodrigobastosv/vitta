enum AppRoute {
  onboarding('/onboarding'),
  home('/'),
  diet('/diet'),
  dietHistory('/diet/history'),
  dietDay('/diet/history/day'),
  foodSearch('/diet/food-search'),
  customFood('/diet/food-search/custom-food'),
  water('/water'),
  sleep('/sleep'),
  workout('/workout'),
  profile('/profile'),
  macroGoals('/profile/macro-goals'),
  settings('/settings'),
  auth('/auth');

  const AppRoute(this.path);

  final String path;
}
