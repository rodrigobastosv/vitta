import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/domain/home/entities/home_feature.dart';
import 'package:vitta/app/domain/home/entities/home_layout.dart';
import 'package:vitta/app/domain/home/entities/home_slot.dart';
import 'package:vitta/app/domain/home/use_cases/get_home_layout_use_case.dart';
import 'package:vitta/app/domain/home/use_cases/save_home_layout_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/home_layout/home_layout_presentation_event.dart';
import 'package:vitta/app/presentation/pages/home_layout/home_layout_state.dart';

class HomeLayoutCubit extends PresentationCubit<HomeLayoutState, HomeLayoutPresentationEvent> {
  HomeLayoutCubit({required GetHomeLayoutUseCase getHomeLayoutUseCase, required this._saveHomeLayoutUseCase})
    : super(HomeLayoutState(layout: getHomeLayoutUseCase()));

  final SaveHomeLayoutUseCase _saveHomeLayoutUseCase;

  Future<void> changeSlot({required HomeFeature feature, required HomeSlot slot}) async {
    await _apply(state.layout.withSlot(feature: feature, slot: slot));
    Log.action('home_layout_slot_changed', data: {'feature': feature.wireValue, 'slot': slot.wireValue});
  }

  Future<void> reorderFeatures({required int oldIndex, required int newIndex}) async {
    await _apply(state.layout.reordered(oldIndex: oldIndex, newIndex: newIndex));
    Log.action('home_layout_reordered');
  }

  Future<void> resetToDefault() async {
    await _apply(HomeLayout.shipped);
    Log.action('home_layout_reset');
    emitPresentation(HomeLayoutReset());
  }

  Future<void> _apply(HomeLayout layout) async {
    emit(state.copyWith(layout: layout));
    await _saveHomeLayoutUseCase(layout: layout);
  }
}
