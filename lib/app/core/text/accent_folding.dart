abstract class AccentFolding {
  static const _foldings = {'a': 'àáâãäå', 'c': 'ç', 'e': 'èéêë', 'i': 'ìíîï', 'n': 'ñ', 'o': 'òóôõö', 'u': 'ùúûü', 'y': 'ýÿ'};

  static final _replacements = {
    for (final MapEntry(:key, :value) in _foldings.entries)
      for (final accented in value.split('')) accented: key,
  };

  static String fold(String value) {
    final lowered = value.toLowerCase();
    return lowered.split('').map((character) => _replacements[character] ?? character).join();
  }
}
