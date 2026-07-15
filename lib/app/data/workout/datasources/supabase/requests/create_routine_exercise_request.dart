class CreateRoutineExerciseRequest {
  CreateRoutineExerciseRequest({required this.routineId, required this.exerciseId, required this.position});

  final String routineId;
  final String exerciseId;
  final int position;

  Map<String, dynamic> toJson() => {'routine_id': routineId, 'exercise_id': exerciseId, 'position': position};
}
