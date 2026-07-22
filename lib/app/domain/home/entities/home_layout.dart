import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/domain/home/entities/home_slot.dart';

class HomeLayout extends Equatable {
  const HomeLayout({required this.order, required this.slots});

  factory HomeLayout.fromWire({required List<String> featureValues, required List<String> slotValues}) {
    final storedOrder = <HomeFeature>[];
    final storedSlots = <HomeFeature, HomeSlot>{};
    for (var index = 0; index < featureValues.length; index++) {
      final feature = HomeFeature.fromWireValue(featureValues[index]);
      if (feature == null || storedOrder.contains(feature)) {
        continue;
      }
      storedOrder.add(feature);
      final slot = index < slotValues.length ? HomeSlot.fromWireValue(slotValues[index]) : null;
      storedSlots[feature] = slot ?? shipped.slotOf(feature);
    }
    if (storedOrder.isEmpty) {
      return shipped;
    }
    for (final feature in shipped.order) {
      if (!storedOrder.contains(feature)) {
        storedOrder.add(feature);
        storedSlots[feature] = shipped.slotOf(feature);
      }
    }
    return HomeLayout(order: storedOrder, slots: storedSlots);
  }

  // The hierarchy the app shipped with: a user who never opens the setting sees
  // exactly this, so changing it changes everyone's home screen.
  static const HomeLayout shipped = HomeLayout(
    order: [HomeFeature.diet, HomeFeature.water, HomeFeature.reminders, HomeFeature.workout, HomeFeature.sleep, HomeFeature.bodyWeight],
    slots: {
      HomeFeature.diet: HomeSlot.hero,
      HomeFeature.water: HomeSlot.supporting,
      HomeFeature.reminders: HomeSlot.supporting,
      HomeFeature.workout: HomeSlot.supporting,
      HomeFeature.sleep: HomeSlot.tile,
      HomeFeature.bodyWeight: HomeSlot.tile,
    },
  );

  final List<HomeFeature> order;
  final Map<HomeFeature, HomeSlot> slots;

  HomeSlot slotOf(HomeFeature feature) => slots[feature] ?? .hidden;

  HomeFeature? get hero => order.where((feature) => slotOf(feature) == .hero).firstOrNull;

  List<HomeFeature> get supporting => _featuresIn(.supporting);

  List<HomeFeature> get tiles => _featuresIn(.tile);

  List<HomeFeature> get hidden => _featuresIn(.hidden);

  List<HomeFeature> _featuresIn(HomeSlot slot) => [
    for (final feature in order)
      if (slotOf(feature) == slot) feature,
  ];

  List<String> get orderWireValues => [for (final feature in order) feature.wireValue];

  List<String> get slotWireValues => [for (final feature in order) slotOf(feature).wireValue];

  HomeLayout withSlot({required HomeFeature feature, required HomeSlot slot}) {
    final updated = {...slots};
    if (slot == .hero) {
      for (final current in order.where((other) => other != feature && slotOf(other) == .hero)) {
        updated[current] = .supporting;
      }
    }
    updated[feature] = slot;
    return HomeLayout(order: order, slots: updated);
  }

  HomeLayout reordered({required int oldIndex, required int newIndex}) {
    final reordered = [...order];
    reordered.insert(newIndex, reordered.removeAt(oldIndex));
    return HomeLayout(order: reordered, slots: slots);
  }

  @override
  List<Object?> get props => [order, slots];
}
