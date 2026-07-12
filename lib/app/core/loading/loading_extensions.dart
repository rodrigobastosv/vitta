import 'package:flutter/widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';

extension BuildContextLoadingExt on BuildContext {
  void showLoading() => loaderOverlay.show();

  void hideLoading() => loaderOverlay.hide();
}
