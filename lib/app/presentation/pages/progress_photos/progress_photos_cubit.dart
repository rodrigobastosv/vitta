import 'dart:typed_data';

import 'package:vitta/app/core/services/image_picker/image_picker_service.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_source.dart';
import 'package:vitta/app/core/services/logging/log.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/domain/progress_photos/use_cases/add_progress_photo_use_case.dart';
import 'package:vitta/app/domain/progress_photos/use_cases/delete_progress_photo_use_case.dart';
import 'package:vitta/app/domain/progress_photos/use_cases/get_progress_photos_use_case.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photos_presentation_event.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photos_state.dart';

class ProgressPhotosCubit extends PresentationCubit<ProgressPhotosState, ProgressPhotosPresentationEvent> {
  ProgressPhotosCubit({
    required this._getProgressPhotosUseCase,
    required this._addProgressPhotoUseCase,
    required this._deleteProgressPhotoUseCase,
    required this._imagePickerService,
  }) : super(const ProgressPhotosState(photos: [], isLoaded: false));

  final GetProgressPhotosUseCase _getProgressPhotosUseCase;
  final AddProgressPhotoUseCase _addProgressPhotoUseCase;
  final DeleteProgressPhotoUseCase _deleteProgressPhotoUseCase;
  final ImagePickerService _imagePickerService;

  static const double _photoMaxWidth = 1600;

  @override
  void onInit() => loadPhotos();

  Future<void> loadPhotos() async {
    final photosResult = await withLoadingOverlay(
      _getProgressPhotosUseCase.call,
      showOverlay: state.isLoaded,
      showLoadingEvent: ProgressPhotosShowLoading(),
      hideLoadingEvent: ProgressPhotosHideLoading(),
    );
    photosResult.when(
      (error) => emitPresentation(ProgressPhotosError(message: error.message)),
      (value) => emit(ProgressPhotosState(photos: value)),
    );
    if (!state.isLoaded) {
      emit(state.copyWith(isLoaded: true));
    }
  }

  Future<void> pickPhoto({required ImagePickerSource source}) async {
    final pickedImage = await _imagePickerService.pickImage(source: source, maxWidth: _photoMaxWidth);
    if (pickedImage == null) {
      return;
    }
    emitPresentation(ProgressPhotoPicked(pickedImage: pickedImage));
  }

  Future<void> addPhoto({required Uint8List bytes, required String fileExtension, required DateTime takenDate, String? note}) async {
    emitPresentation(ProgressPhotosShowLoading());
    final addedResult = await _addProgressPhotoUseCase(bytes: bytes, fileExtension: fileExtension, takenDate: takenDate, note: note);
    emitPresentation(ProgressPhotosHideLoading());
    await addedResult.when((error) => Future.sync(() => emitPresentation(ProgressPhotosError(message: error.message))), (_) async {
      Log.action('progress_photo_added');
      emitPresentation(ProgressPhotoAdded());
      await loadPhotos();
    });
  }

  Future<void> deletePhoto({required ProgressPhoto photo}) async {
    final previous = state.photos;
    emit(
      state.copyWith(
        photos: [
          for (final candidate in previous)
            if (candidate.id != photo.id) candidate,
        ],
      ),
    );
    final deletedResult = await _deleteProgressPhotoUseCase(photoId: photo.id, storagePath: photo.storagePath);
    deletedResult.when((error) {
      emit(state.copyWith(photos: previous));
      emitPresentation(ProgressPhotosError(message: error.message));
    }, (_) => Log.action('progress_photo_deleted'));
  }
}
