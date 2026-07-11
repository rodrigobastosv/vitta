enum AppRoute {
  home('/'),
  diet('/diet'),
  workout('/workout'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;
}
