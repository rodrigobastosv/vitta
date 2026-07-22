import 'package:vitta/app/core/services/storage/local_storage_service.dart';
import 'package:vitta/app/domain/home/entities/home_layout.dart';

class HomeLayoutLocalDataSource {
  HomeLayoutLocalDataSource({required this._localStorageService});

  final LocalStorageService _localStorageService;

  static const _orderKey = 'home.layoutOrder';
  static const _slotsKey = 'home.layoutSlots';

  HomeLayout getHomeLayout() => HomeLayout.fromWire(
    featureValues: _localStorageService.get<List<dynamic>>(_orderKey)?.cast<String>() ?? const [],
    slotValues: _localStorageService.get<List<dynamic>>(_slotsKey)?.cast<String>() ?? const [],
  );

  Future<void> saveHomeLayout(HomeLayout layout) async {
    await _localStorageService.put(_orderKey, layout.orderWireValues);
    await _localStorageService.put(_slotsKey, layout.slotWireValues);
  }
}
