class UpdateRoutineRequest {
  UpdateRoutineRequest({required this.name});

  final String name;

  Map<String, dynamic> toJson() => {'name': name};
}
