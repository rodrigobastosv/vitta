import 'package:go_router/go_router.dart';
import 'package:vitta/app/domain/trends/entities/progress_story.dart';
import 'package:vitta/app/presentation/pages/share_progress/share_progress_page.dart';
import 'package:vitta/app/presentation/routing/app_route.dart';
import 'package:vitta/app/presentation/routing/vt_route.dart';

class ShareProgressRoute extends VTRoute {
  @override
  AppRoute get route => .shareProgress;

  // The trends page already holds every figure the card renders, so the story
  // rides in on the route rather than a second round of range queries - the
  // DietDayPage reasoning.
  @override
  GoRouterWidgetBuilder get builder => (context, state) {
    final story = state.extra! as ProgressStory;
    return ShareProgressPage(story: story);
  };
}
