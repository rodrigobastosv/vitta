import 'package:image_picker/image_picker.dart';

enum ImagePickerSource {
  camera(ImageSource.camera),
  gallery(ImageSource.gallery);

  const ImagePickerSource(this.source);

  final ImageSource source;
}
