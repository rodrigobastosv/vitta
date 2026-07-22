import 'package:vitta/app/core/services/image_picker/picked_image.dart';

sealed class ProgressPhotosPresentationEvent {}

class ProgressPhotosShowLoading implements ProgressPhotosPresentationEvent {}

class ProgressPhotosHideLoading implements ProgressPhotosPresentationEvent {}

class ProgressPhotosError implements ProgressPhotosPresentationEvent {
  const ProgressPhotosError({required this.message});

  final String message;
}

class ProgressPhotoPicked implements ProgressPhotosPresentationEvent {
  const ProgressPhotoPicked({required this.pickedImage});

  final PickedImage pickedImage;
}

class ProgressPhotoAdded implements ProgressPhotosPresentationEvent {}
