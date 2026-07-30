import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/trends/entities/progress_story.dart';

class ShareProgressState extends Equatable {
  const ShareProgressState({required this.story});

  final ProgressStory story;

  @override
  List<Object?> get props => [story];
}
