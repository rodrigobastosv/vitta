import 'package:image_picker/image_picker.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_source.dart';
import 'package:vitta/app/core/services/image_picker/picked_image.dart';

class ImagePickerService {
  ImagePickerService({ImagePicker? imagePicker}) : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  static const String _fallbackFileExtension = 'jpg';

  Future<PickedImage?> pickImage({required ImagePickerSource source, required double maxWidth}) async {
    final pickedFile = await _imagePicker.pickImage(source: source.source, maxWidth: maxWidth);
    if (pickedFile == null) {
      return null;
    }
    return PickedImage(
      path: pickedFile.path,
      bytes: await pickedFile.readAsBytes(),
      fileExtension: pickedFile.name.contains('.') ? pickedFile.name.split('.').last : _fallbackFileExtension,
    );
  }
}
