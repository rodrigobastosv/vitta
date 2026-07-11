import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:vitta/app/core/services/storage/local_storage_service.dart';

/// Opens a real Hive box against a fresh temp directory and registers its own
/// cleanup via [addTearDown], so callers never juggle a box/tempDir pair.
Future<Box<dynamic>> openTestHiveBox() async {
  final tempDir = await Directory.systemTemp.createTemp('vitta_test_hive');
  Hive.init(tempDir.path);
  final box = await Hive.openBox<dynamic>('test_${DateTime.now().microsecondsSinceEpoch}');
  addTearDown(() async {
    await box.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });
  return box;
}

Future<LocalStorageService> buildTestLocalStorageService() async => LocalStorageService(box: await openTestHiveBox());
