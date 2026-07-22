enum HomeSlot {
  hero('hero'),
  supporting('supporting'),
  tile('tile'),
  hidden('hidden');

  const HomeSlot(this.wireValue);

  final String wireValue;

  static HomeSlot? fromWireValue(String? value) {
    for (final slot in HomeSlot.values) {
      if (slot.wireValue == value) {
        return slot;
      }
    }
    return null;
  }
}
