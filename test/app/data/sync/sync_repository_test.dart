import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/services/supabase/supabase_table.dart';
import 'package:vitta/app/data/sync/sync_repository.dart';
import 'package:vitta/app/domain/sync/entities/sync_topic.dart';

import '../../../mocks/services_mocks.dart';

void main() {
  test('watches every table a topic is spread across', () async {
    final realtimeService = MockRealtimeService();
    when(() => realtimeService.changes(any())).thenAnswer((_) => const Stream<SupabaseTable>.empty());
    final repository = SyncRepository(realtimeService: realtimeService);

    await repository.changes(topics: const {SyncTopic.workout}).drain<void>();

    verify(
      () => realtimeService.changes({SupabaseTable.workouts, SupabaseTable.workoutExercises, SupabaseTable.workoutSets}),
    ).called(1);
  });

  test('reports the topic a changed table belongs to, not the table', () async {
    final realtimeService = MockRealtimeService();
    when(() => realtimeService.changes(any())).thenAnswer((_) => Stream.fromIterable([SupabaseTable.workoutSets, SupabaseTable.foodLogs]));
    final repository = SyncRepository(realtimeService: realtimeService);

    final topics = await repository.changes(topics: const {SyncTopic.workout, SyncTopic.diet}).toList();

    expect(topics, [SyncTopic.workout, SyncTopic.diet]);
  });

  test('a topic nobody asked for is dropped rather than delivered', () async {
    final realtimeService = MockRealtimeService();
    when(() => realtimeService.changes(any())).thenAnswer((_) => Stream.fromIterable([SupabaseTable.waterLogs, SupabaseTable.foodLogs]));
    final repository = SyncRepository(realtimeService: realtimeService);

    final topics = await repository.changes(topics: const {SyncTopic.diet}).toList();

    expect(topics, [SyncTopic.diet]);
  });
}
