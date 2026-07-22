import 'package:go_router/go_router.dart';
import 'package:vitta/app/presentation/pages/progress_photo_compare/progress_photo_compare_extra.dart';
import 'package:vitta/app/presentation/pages/progress_photo_compare/progress_photo_compare_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class ProgressPhotoCompareRoute extends VTRoute {
  @override
  AppRoute get route => .progressPhotoCompare;

  @override
  GoRouterWidgetBuilder get builder => (context, state) {
    final extra = state.extra! as ProgressPhotoCompareExtra;
    return ProgressPhotoComparePage(photos: extra.photos);
  };
}
