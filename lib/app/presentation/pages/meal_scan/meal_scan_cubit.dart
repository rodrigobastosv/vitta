import 'package:vitta/app/core/error/premium_required_error.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_service.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_source.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/domain/diet/entities/meal_type.dart';
import 'package:vitta/app/domain/diet/entities/scanned_meal.dart';
import 'package:vitta/app/domain/diet/use_cases/log_scanned_meal_use_case.dart';
import 'package:vitta/app/domain/diet/use_cases/scan_meal_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_entry.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_presentation_event.dart';
import 'package:vitta/app/presentation/pages/meal_scan/meal_scan_state.dart';

class MealScanCubit extends PresentationCubit<MealScanState, MealScanPresentationEvent> {
  MealScanCubit({required this._scanMealUseCase, required this._logScannedMealUseCase, required this._imagePickerService, required this._loggedDate})
    : super(MealScanState(mealType: _mealTypeForNow()));

  final ScanMealUseCase _scanMealUseCase;
  final LogScannedMealUseCase _logScannedMealUseCase;
  final ImagePickerService _imagePickerService;
  final DateTime _loggedDate;

  static const double _mealPhotoMaxWidth = 1600;

  Future<void> scanMeal({required ImagePickerSource source}) async {
    final pickedImage = await _imagePickerService.pickImage(source: source, maxWidth: _mealPhotoMaxWidth);
    if (pickedImage == null) {
      return;
    }
    emit(state.copyWith(imageBytes: pickedImage.bytes));
    emitPresentation(MealScanScanning(imageBytes: pickedImage.bytes));
    final scannedMealResult = await _scanMealUseCase(imagePath: pickedImage.path);
    emitPresentation(MealScanHideLoading());
    scannedMealResult.when(_onScanFailed, _applyScannedMeal);
  }

  void _onScanFailed(VTError error) => emitPresentation(error is PremiumRequiredError ? MealScanPremiumRequired() : MealScanError(message: error.message));

  void _applyScannedMeal(ScannedMeal meal) {
    if (!meal.hasItems) {
      emit(state.copyWith(entries: const [], hasScanned: true));
      emitPresentation(MealScanFoundNothing());
      return;
    }
    emit(
      state.copyWith(
        hasScanned: true,
        entries: [for (final item in meal.items) MealScanEntry(item: item, gramsText: _formatGrams(item.estimatedGrams))],
      ),
    );
  }

  void gramsChanged({required int index, required String text}) => emit(
    state.copyWith(
      entries: [
        for (final (i, entry) in state.entries.indexed)
          if (i == index) entry.copyWith(gramsText: text) else entry,
      ],
    ),
  );

  void toggleIncluded({required int index}) => emit(
    state.copyWith(
      entries: [
        for (final (i, entry) in state.entries.indexed)
          if (i == index) entry.copyWith(isIncluded: !entry.isIncluded) else entry,
      ],
    ),
  );

  void mealTypeChanged(MealType mealType) => emit(state.copyWith(mealType: mealType));

  Future<void> logMeal() async {
    final includedEntries = state.includedEntries;
    if (!state.canLog) {
      emitPresentation(MealScanIncomplete());
      return;
    }
    emitPresentation(MealScanShowLoading());
    final loggedResult = await _logScannedMealUseCase(
      items: [for (final entry in includedEntries) ScannedMealLogItem(item: entry.item, quantityGrams: entry.quantityGrams!)],
      loggedDate: _loggedDate,
      mealType: state.mealType,
    );
    emitPresentation(MealScanHideLoading());
    loggedResult.when((error) => emitPresentation(MealScanError(message: error.message)), (_) {
      Log.action(.mealLoggedFromScan, data: {'meal': state.mealType.wireValue, 'items': includedEntries.length});
      emitPresentation(MealScanLogged(mealType: state.mealType, itemCount: includedEntries.length));
    });
  }

  static MealType _mealTypeForNow() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return MealType.breakfast;
    }
    if (hour < 15) {
      return MealType.lunch;
    }
    if (hour < 21) {
      return MealType.dinner;
    }
    return MealType.snack;
  }

  static String _formatGrams(double grams) => grams == grams.roundToDouble() ? grams.toStringAsFixed(0) : grams.toStringAsFixed(1);
}
