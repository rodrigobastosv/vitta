import 'dart:typed_data';

class PickedImage {
  const PickedImage({required this.path, required this.bytes, required this.fileExtension});

  final String path;
  final Uint8List bytes;
  final String fileExtension;
}
