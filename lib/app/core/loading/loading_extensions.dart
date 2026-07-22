import 'package:flutter/widgets.dart';
import 'package:loader_overlay/loader_overlay.dart';

extension BuildContextLoadingExt on BuildContext {
  // Passing [widget] swaps the default spinner for a custom overlay (e.g. the AI
  // scanning animation); omitting it falls back to the app-wide indicator.
  void showLoading({Widget? widget}) => loaderOverlay.show(widgetBuilder: widget == null ? null : (_) => widget);

  void hideLoading() => loaderOverlay.hide();
}
