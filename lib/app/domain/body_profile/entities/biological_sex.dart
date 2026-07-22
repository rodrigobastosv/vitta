enum BiologicalSex {
  male(mifflinConstant: 5),
  female(mifflinConstant: -161);

  const BiologicalSex({required this.mifflinConstant});

  static BiologicalSex? fromWireValue(String? value) {
    for (final sex in values) {
      if (sex.wireValue == value) {
        return sex;
      }
    }
    return null;
  }

  static const double unknownMifflinConstant = -78;

  final double mifflinConstant;

  String get wireValue => name;
}
