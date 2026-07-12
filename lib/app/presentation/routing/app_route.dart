enum AppRoute {
  home('/'),
  diet('/diet'),
  foodSearch('/diet/food-search'),
  water('/water'),
  workout('/workout'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;
}
