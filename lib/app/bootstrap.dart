import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/env/env.dart';
import 'package:vitta/app/core/services/supabase/supabase_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabasePublishableKey);
  final supabaseService = SupabaseService(client: Supabase.instance.client);
  if (!supabaseService.hasSession) {
    await supabaseService.auth.signInAnonymously();
  }
  await Hive.initFlutter();
  final appBox = await Hive.openBox<dynamic>('app');
  setupDependencies(appBox: appBox, supabaseService: supabaseService);
}
