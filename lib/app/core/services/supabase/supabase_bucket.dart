enum SupabaseBucket {
  foodImages('food-images'),
  exerciseImages('exercise-images'),
  avatars('avatars'),
  progressPhotos('progress-photos');

  const SupabaseBucket(this.wireName);

  final String wireName;
}
