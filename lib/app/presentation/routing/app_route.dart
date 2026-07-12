enum AppRoute {
  onboarding('/onboarding'),
  home('/'),
  diet('/diet'),
  foodSearch('/diet/food-search'),
  water('/water'),
  sleep('/sleep'),
  workout('/workout'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;
}
