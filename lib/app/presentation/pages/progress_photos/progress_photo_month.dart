import 'package:equatable/equatable.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photo_day.dart';

class ProgressPhotoMonth extends Equatable {
  const ProgressPhotoMonth({required this.month, required this.days});

  final DateTime month;
  final List<ProgressPhotoDay> days;

  @override
  List<Object?> get props => [month, days];
}
