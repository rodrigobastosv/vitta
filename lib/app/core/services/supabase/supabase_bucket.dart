enum SupabaseBucket {
  foodImages('food-images'),
  exerciseImages('exercise-images'),
  avatars('avatars');

  const SupabaseBucket(this.wireName);

  final String wireName;
}
