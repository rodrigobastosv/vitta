import 'dart:typed_data';

import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/data/diet/diet_repository.dart';

class UploadFoodImageUseCase {
  UploadFoodImageUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<Result<VTError, String>> call({required Uint8List bytes, required String fileExtension}) =>
      _dietRepository.uploadFoodImage(bytes: bytes, fileExtension: fileExtension);
}
