enum AppRoute {
  onboarding('/onboarding'),
  home('/'),
  diet('/diet'),
  foodSearch('/diet/food-search'),
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
