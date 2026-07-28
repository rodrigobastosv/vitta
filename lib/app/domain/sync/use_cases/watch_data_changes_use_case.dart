import 'package:vitta/app/data/sync/sync_repository.dart';
import 'package:vitta/app/domain/sync/entities/sync_topic.dart';

class WatchDataChangesUseCase {
  WatchDataChangesUseCase({required this._syncRepository});

  final SyncRepository _syncRepository;

  Stream<SyncTopic> call({required Set<SyncTopic> topics}) => _syncRepository.changes(topics: topics);
}
