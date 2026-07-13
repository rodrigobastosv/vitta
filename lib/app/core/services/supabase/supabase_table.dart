enum SupabaseTable {
  foods('foods'),
  foodLogs('food_logs'),
  waterLogs('water_logs'),
  sleepLogs('sleep_logs');

  const SupabaseTable(this.wireName);

  final String wireName;
}
