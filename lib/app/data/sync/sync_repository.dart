import 'package:vitta/app/core/services/supabase/realtime_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_table.dart';
import 'package:vitta/app/domain/sync/entities/sync_topic.dart';

class SyncRepository {
  SyncRepository({required this._realtimeService});

  final RealtimeService _realtimeService;

  static const _tablesByTopic = <SyncTopic, Set<SupabaseTable>>{
    SyncTopic.diet: {SupabaseTable.foodLogs},
    SyncTopic.water: {SupabaseTable.waterLogs},
    SyncTopic.reminders: {SupabaseTable.reminders},
    SyncTopic.sleep: {SupabaseTable.sleepLogs},
    SyncTopic.bodyWeight: {SupabaseTable.bodyWeightLogs},
    SyncTopic.workout: {SupabaseTable.workouts, SupabaseTable.workoutExercises, SupabaseTable.workoutSets},
  };

  Stream<SyncTopic> changes({required Set<SyncTopic> topics}) {
    final tables = {for (final topic in topics) ...?_tablesByTopic[topic]};
    return _realtimeService.changes(tables).map(_topicOf).where(topics.contains);
  }

  static SyncTopic _topicOf(SupabaseTable table) =>
      _tablesByTopic.entries.firstWhere((entry) => entry.value.contains(table)).key;
}
