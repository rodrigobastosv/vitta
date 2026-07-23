import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/domain/home/entities/home_layout.dart';
import 'package:vitta/app/domain/home/entities/home_slot.dart';

void main() {
  test('the shipped layout is the hierarchy the home screen already had', () {
    const layout = HomeLayout.shipped;

    expect(layout.heroes, [HomeFeature.diet]);
    expect(layout.supporting, [HomeFeature.water, HomeFeature.reminders, HomeFeature.workout]);
    expect(layout.tiles, [HomeFeature.sleep, HomeFeature.bodyWeight]);
    expect(layout.hidden, isEmpty);
  });

  test('a second headline joins the first rather than replacing it, in the layout order', () {
    final layout = HomeLayout.shipped.withSlot(feature: HomeFeature.workout, slot: HomeSlot.hero);

    expect(layout.heroes, [HomeFeature.diet, HomeFeature.workout]);
    expect(layout.slotOf(HomeFeature.diet), HomeSlot.hero);
  });

  test('hiding a feature drops it from every visible section', () {
    final layout = HomeLayout.shipped.withSlot(feature: HomeFeature.sleep, slot: HomeSlot.hidden);

    expect(layout.tiles, [HomeFeature.bodyWeight]);
    expect(layout.hidden, [HomeFeature.sleep]);
  });

  test('reordering moves a feature to the index the reorder handed back', () {
    final layout = HomeLayout.shipped.reordered(oldIndex: 0, newIndex: 2);

    expect(layout.order, [HomeFeature.water, HomeFeature.reminders, HomeFeature.diet, HomeFeature.workout, HomeFeature.sleep, HomeFeature.bodyWeight]);
  });

  test('a stored layout round-trips through its wire values', () {
    final saved = HomeLayout.shipped.withSlot(feature: HomeFeature.workout, slot: HomeSlot.hero).reordered(oldIndex: 3, newIndex: 0);

    final read = HomeLayout.fromWire(featureValues: saved.orderWireValues, slotValues: saved.slotWireValues);

    expect(read, saved);
  });

  test('nothing stored reads back as the shipped layout', () {
    expect(HomeLayout.fromWire(featureValues: const [], slotValues: const []), HomeLayout.shipped);
  });

  test('a feature missing from a stored layout is appended with its shipped slot', () {
    final read = HomeLayout.fromWire(featureValues: const ['workout', 'diet'], slotValues: const ['hero', 'hidden']);

    expect(read.heroes, [HomeFeature.workout]);
    expect(read.slotOf(HomeFeature.diet), HomeSlot.hidden);
    expect(read.order.take(2), [HomeFeature.workout, HomeFeature.diet]);
    expect(read.slotOf(HomeFeature.sleep), HomeSlot.tile);
    expect(read.order.length, HomeFeature.values.length);
  });

  test('an unknown wire value is ignored rather than crashing the read', () {
    final read = HomeLayout.fromWire(featureValues: const ['meditation', 'water'], slotValues: const ['hero', 'hero']);

    expect(read.heroes.first, HomeFeature.water);
    expect(read.order.contains(HomeFeature.water), isTrue);
  });
}
