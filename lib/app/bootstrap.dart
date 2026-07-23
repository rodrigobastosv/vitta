import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/env/env.dart';
import 'package:vitta/app/core/services/analytics/analytics_service.dart';
import 'package:vitta/app/core/services/notifications/notification_service.dart';
import 'package:vitta/app/core/services/purchases/purchase_service.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';
import 'package:vitta/app/presentation/routing/notification_navigator.dart';

Future<void> bootstrap({required AppRunner appRunner}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await SentryFlutter.init(
    (options) => options.dsn = Env.sentryDsn,
    appRunner: () async {
      await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabasePublishableKey);
      final supabaseService = SupabaseService(client: Supabase.instance.client);
      if (!supabaseService.hasSession) {
        await supabaseService.auth.signInAnonymously();
      }
      await Hive.initFlutter();
      final appBox = await Hive.openBox<dynamic>('app');
      setupDependencies(appBox: appBox, supabaseService: supabaseService);
      final notificationService = G<NotificationService>();
      await notificationService.init();
      await NotificationNavigator.start(notificationService);
      await G<PurchaseService>().init();
      final analyticsService = G<AnalyticsService>();
      await analyticsService.init();
      analyticsService.setUserId(supabaseService.currentUserId);
      await appRunner();
    },
  );
}
