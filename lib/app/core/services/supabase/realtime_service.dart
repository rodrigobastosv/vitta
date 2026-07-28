import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitta/app/core/services/supabase/supabase_table.dart';

/// Postgres change notifications for the tables a screen cares about, as a
/// stream of the [SupabaseTable] that changed. It deliberately reports *that*
/// something changed rather than *what* it now is: a `postgres_changes` payload
/// is the raw row, and nothing this app renders is a raw row (a `food_logs`
/// insert carries no joined `foods`, so it has no calories in it). Subscribers
/// re-read the section instead, which is authoritative and — because it also
/// settles the client's own optimistic write — cannot double-count an echo of a
/// change this device just made.
///
/// Realtime has no replay: a socket suspended with the app misses every event
/// fired while it was away, and Supabase will not resend them. So this is an
/// optimization over the ordinary reads, never a replacement for them, and every
/// watched table is re-emitted on resume so a subscriber re-reads whatever it
/// slept through.
class RealtimeService with WidgetsBindingObserver {
  RealtimeService({required this._client}) {
    WidgetsBinding.instance.addObserver(this);
  }

  final SupabaseClient _client;
  final Set<_TableWatch> _watches = {};

  var _channelSeed = 0;

  Stream<SupabaseTable> changes(Set<SupabaseTable> tables) {
    final controller = StreamController<SupabaseTable>.broadcast();
    final watch = _TableWatch(tables: tables, controller: controller);
    RealtimeChannel? channel;

    controller
      ..onListen = () {
        _watches.add(watch);
        channel = _client.channel('vitta-sync-${_channelSeed++}');
        for (final table in tables) {
          channel!.onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: table.wireName,
            callback: (_) => watch.notify(table),
          );
        }
        channel!.subscribe();
      }
      ..onCancel = () async {
        _watches.remove(watch);
        await channel?.unsubscribe();
        await controller.close();
      };

    return controller.stream;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }
    for (final watch in _watches) {
      watch.tables.forEach(watch.notify);
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}

class _TableWatch {
  _TableWatch({required this.tables, required this.controller});

  final Set<SupabaseTable> tables;
  final StreamController<SupabaseTable> controller;

  void notify(SupabaseTable table) {
    if (!controller.isClosed) {
      controller.add(table);
    }
  }
}
