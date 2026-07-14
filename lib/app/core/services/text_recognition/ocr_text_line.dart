import 'package:equatable/equatable.dart';

/// One recognized line of text plus the vertical/horizontal position of its
/// bounding box, so a columnar layout (label in one column, value in another)
/// can be reassembled into visual rows.
class OcrTextLine extends Equatable {
  const OcrTextLine({required this.text, required this.top, required this.bottom, required this.left});

  final String text;
  final double top;
  final double bottom;
  final double left;

  @override
  List<Object?> get props => [text, top, bottom, left];
}
