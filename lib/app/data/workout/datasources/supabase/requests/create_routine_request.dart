class CreateRoutineRequest {
  CreateRoutineRequest({required this.userId, required this.name, required this.position});

  final String userId;
  final String name;
  final int position;

  Map<String, dynamic> toJson() => {'user_id': userId, 'name': name, 'position': position};
}
