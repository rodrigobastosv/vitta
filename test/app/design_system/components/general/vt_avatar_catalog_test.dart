import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_avatar_catalog.dart';

void main() {
  test('byId resolves a known option and returns null otherwise', () {
    expect(VTAvatarCatalog.byId('man-light')?.id, 'man-light');
    expect(VTAvatarCatalog.byId('nope'), isNull);
    expect(VTAvatarCatalog.byId(null), isNull);
  });

  test('every option has a unique id, a face and a two-colour gradient', () {
    final ids = VTAvatarCatalog.options.map((option) => option.id).toList();

    expect(ids.toSet().length, ids.length);
    expect(VTAvatarCatalog.options.every((option) => option.emoji.isNotEmpty), isTrue);
    expect(VTAvatarCatalog.options.every((option) => option.colors.length >= 2), isTrue);
  });
}
