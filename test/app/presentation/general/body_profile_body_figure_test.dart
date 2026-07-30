import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/design_system/components/general/vt_body_figure.dart';
import 'package:vitta/app/domain/body_profile/entities/biological_sex.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';
import 'package:vitta/app/presentation/general/body_profile_body_figure.dart';

void main() {
  test('draws the figure matching the stated sex', () {
    expect(const BodyProfile(sex: BiologicalSex.male).bodyFigure, VTBodyFigure.male);
    expect(const BodyProfile(sex: BiologicalSex.female).bodyFigure, VTBodyFigure.female);
  });

  test('falls back to a named figure when the body step was skipped', () {
    expect(const BodyProfile().sex, isNull);
    expect(const BodyProfile().bodyFigure, BodyProfileBodyFigure.figureWhenSexUnstated);
  });
}
