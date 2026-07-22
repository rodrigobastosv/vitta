import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';

class ProgressPhotoDay extends Equatable {
  const ProgressPhotoDay({required this.day, required this.photos});

  final DateTime day;
  final List<ProgressPhoto> photos;

  @override
  List<Object?> get props => [day, photos];
}
