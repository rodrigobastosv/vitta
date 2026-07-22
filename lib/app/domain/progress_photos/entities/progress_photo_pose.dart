enum ProgressPhotoPose {
  front,
  side,
  back,
  other;

  static ProgressPhotoPose fromWireValue(String? value) => switch (value) {
    'front' => .front,
    'side' => .side,
    'back' => .back,
    _ => .other,
  };

  String get wireValue => switch (this) {
    .front => 'front',
    .side => 'side',
    .back => 'back',
    .other => 'other',
  };
}
