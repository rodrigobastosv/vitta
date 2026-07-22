import 'package:flutter_test/flutter_test.dart';
import 'package:vitta/app/data/home/home_layout_local_datasource.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/domain/home/entities/home_layout.dart';
import 'package:vitta/app/domain/home/entities/home_slot.dart';

import '../../../fixtures/local_storage_fixture.dart';

void main() {
  test('getHomeLayout defaults to the shipped hierarchy when nothing was saved', () async {
    final dataSource = HomeLayoutLocalDataSource(localStorageService: await buildTestLocalStorageService());

    expect(dataSource.getHomeLayout(), HomeLayout.shipped);
  });

  test('a saved layout is read back exactly as it was written', () async {
    final dataSource = HomeLayoutLocalDataSource(localStorageService: await buildTestLocalStorageService());
    final layout = HomeLayout.shipped
        .withSlot(feature: HomeFeature.bodyWeight, slot: HomeSlot.hero)
        .withSlot(feature: HomeFeature.reminders, slot: HomeSlot.hidden)
        .reordered(oldIndex: 5, newIndex: 0);

    await dataSource.saveHomeLayout(layout);

    expect(dataSource.getHomeLayout(), layout);
  });
}
