import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/env/env.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/cubit/app_state.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/presentation/routing/app_router.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabasePublishableKey);
  if (Supabase.instance.client.auth.currentSession == null) {
    await Supabase.instance.client.auth.signInAnonymously();
  }
  setupDependencies();
  runApp(const VittaApp());
}

class VittaApp extends StatelessWidget {
  const VittaApp({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<AppCubit>.value(
    value: G<AppCubit>(),
    child: BlocBuilder<AppCubit, AppState>(
      builder: (context, state) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: VTTheme.light,
        darkTheme: VTTheme.dark,
        themeMode: state.themeMode,
        locale: state.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: AppRouter.router,
      ),
    ),
  );
}
