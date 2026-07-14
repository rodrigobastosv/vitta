import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/text_recognition/ocr_text_line.dart';
import 'package:vitta/app/core/services/text_recognition/text_recognition_service.dart';

class NutritionOcrDataSource {
  NutritionOcrDataSource({required this._textRecognitionService});

  final TextRecognitionService _textRecognitionService;

  Future<Result<VTError, List<OcrTextLine>>> recognizeText({required String imagePath}) async {
    try {
      final lines = await _textRecognitionService.recognizeText(imagePath: imagePath);
      return Success(lines);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Failed to read nutrition label', cause: error));
    }
  }
}
