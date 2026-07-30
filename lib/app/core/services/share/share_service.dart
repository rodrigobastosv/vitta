import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';
import 'package:vitta/app/core/services/share/share_outcome.dart';

/// Thin adapter over `share_plus` so nothing above core/services/ imports the
/// package directly — the same boundary NotificationService, PurchaseService and
/// ImagePickerService establish. It speaks the app's own ShareOutcome rather
/// than share_plus's ShareResult, and takes plain bytes rather than an XFile.
class ShareService {
  ShareService({SharePlus? sharePlus}) : _sharePlus = sharePlus ?? SharePlus.instance;

  final SharePlus _sharePlus;

  static const String _pngMimeType = 'image/png';

  Future<ShareOutcome> shareImage({required Uint8List bytes, required String fileName, required String message}) async {
    try {
      final shareResult = await _sharePlus.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: _pngMimeType, name: fileName)],
          // cross_file drops the name of an in-memory file on every platform but
          // web, so without this the receiving app is handed an unnamed blob.
          fileNameOverrides: [fileName],
          text: message,
        ),
      );
      return switch (shareResult.status) {
        // The platform shared but cannot say what the user picked; there is
        // nothing to apologise for, so it reads as shared rather than failed.
        .success || .unavailable => .shared,
        .dismissed => .dismissed,
      };
    } on Exception {
      return .failed;
    }
  }
}
