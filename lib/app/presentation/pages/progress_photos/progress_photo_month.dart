import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';

class ProgressPhotoMonth extends Equatable {
  const ProgressPhotoMonth({required this.month, required this.photos});

  final DateTime month;
  final List<ProgressPhoto> photos;

  @override
  List<Object?> get props => [month, photos];
}
