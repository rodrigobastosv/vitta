import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/progress_photos/entities/progress_photo.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photo_day.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photo_month.dart';

class ProgressPhotosState extends Equatable {
  const ProgressPhotosState({required this.photos, this.isLoaded = true});

  final List<ProgressPhoto> photos;
  final bool isLoaded;

  ProgressPhoto? get latest => photos.isEmpty ? null : photos.first;

  ProgressPhoto? get oldest => photos.isEmpty ? null : photos.last;

  bool get canCompare => photos.length > 1;

  List<ProgressPhotoMonth> get months {
    final byDay = <DateTime, List<ProgressPhoto>>{};
    for (final photo in photos) {
      byDay.putIfAbsent(photo.takenDay, () => []).add(photo);
    }
    final byMonth = <DateTime, List<ProgressPhotoDay>>{};
    for (final entry in byDay.entries) {
      final dayPhotos = [...entry.value]..sort((first, second) => first.pose.index.compareTo(second.pose.index));
      byMonth.putIfAbsent(DateTime(entry.key.year, entry.key.month), () => []).add(ProgressPhotoDay(day: entry.key, photos: dayPhotos));
    }
    return [for (final entry in byMonth.entries) ProgressPhotoMonth(month: entry.key, days: entry.value)];
  }

  ProgressPhotosState copyWith({List<ProgressPhoto>? photos, bool? isLoaded}) =>
      ProgressPhotosState(photos: photos ?? this.photos, isLoaded: isLoaded ?? this.isLoaded);

  @override
  List<Object?> get props => [photos, isLoaded];
}
