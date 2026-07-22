import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _allowed = {
  // A network retry backoff, not motion.
  'lib/app/core/http/vt_http_client.dart',
  // A continuous spinner loop, not a transition between two states.
  'lib/app/design_system/components/general/vt_loading_overlay_indicator.dart',
  // A search debounce is an input delay, not a transition - the same category
  // as the HTTP retry backoff above.
  'lib/app/presentation/pages/add_food/add_food_cubit.dart',
  // A continuous pulse, same as the spinner above. easeInOut is deliberate: a
  // pulse breathes symmetrically, where VTMotion.curve eases out of a change.
  'lib/app/design_system/components/general/vt_skeleton.dart',
  // A continuous wave loop, not a transition - the fill level itself still
  // animates through VTMotion.data; only the surface ripple loops.
  'lib/app/design_system/components/general/vt_water_fill.dart',
  // A continuous scan-line sweep and caption rotation while an AI scan runs,
  // not a transition between two states - same category as the spinner.
  'lib/app/design_system/components/general/vt_scanning_overlay.dart',
};

void main() {
  test('every animation duration and curve comes from VTMotion', () {
    final offenders = <String>[];
    final literal = RegExp(r'Duration\(milliseconds:|Curves\.');

    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      final path = file.path;
      if (!path.endsWith('.dart') || path.endsWith('vt_motion.dart') || _allowed.contains(path)) {
        continue;
      }
      final source = file.readAsStringSync();
      for (final line in source.split('\n').indexed) {
        if (literal.hasMatch(line.$2)) {
          offenders.add('$path:${line.$1 + 1}  ${line.$2.trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Motion is a shared language, not per-screen taste — 17 different stagger formulas is what\n'
          'prompted these tokens. Use VTMotion.micro/transition/entrance/data and VTMotion.curve,\n'
          'or add the file to _allowed if it genuinely is not a transition:\n${offenders.join('\n')}',
    );
  });
}
