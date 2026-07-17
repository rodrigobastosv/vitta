import 'package:equatable/equatable.dart';

/// A sleep session pulled from the device health platform, ready to be persisted.
/// Keeps `core/services` health types out of the domain/data layers.
class SleepImport extends Equatable {
  const SleepImport({required this.start, required this.end, required this.externalId});

  final DateTime start;
  final DateTime end;
  final String externalId;

  @override
  List<Object?> get props => [start, end, externalId];
}
