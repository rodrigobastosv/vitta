import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photos_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class ProgressPhotosRoute extends VTRoute {
  @override
  AppRoute get route => .progressPhotos;

  @override
  GoRouterWidgetBuilder get builder =>
      (context, state) => const ProgressPhotosPage();
}
