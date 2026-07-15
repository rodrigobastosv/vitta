enum SupabaseBucket {
  foodImages('food-images'),
  exerciseImages('exercise-images');

  const SupabaseBucket(this.wireName);

  final String wireName;
}
