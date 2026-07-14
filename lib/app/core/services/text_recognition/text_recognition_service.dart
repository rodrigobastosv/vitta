import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:vitta/app/core/services/text_recognition/ocr_text_line.dart';

class TextRecognitionService {
  TextRecognitionService({TextRecognizer? textRecognizer}) : _textRecognizer = textRecognizer ?? TextRecognizer();

  final TextRecognizer _textRecognizer;

  Future<List<OcrTextLine>> recognizeText({required String imagePath}) async {
    final recognizedText = await _textRecognizer.processImage(InputImage.fromFilePath(imagePath));
    return [
      for (final block in recognizedText.blocks)
        for (final line in block.lines)
          OcrTextLine(text: line.text, top: line.boundingBox.top, bottom: line.boundingBox.bottom, left: line.boundingBox.left),
    ];
  }
}
