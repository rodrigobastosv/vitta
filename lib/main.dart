import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:vitta/app/bootstrap.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/cubit/premium_cubit.dart';
import 'package:vitta/app/cubit/rest_timer_cubit.dart';
import 'package:vitta/app/design_system/components/general/vt_loading_overlay_indicator.dart';
import 'package:vitta/app/design_system/themes/vt_theme.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/presentation/routing/app_router.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

Future<void> main() async {
  await bootstrap(appRunner: () => runApp(const VittaApp()));
}

class VittaApp extends StatelessWidget {
  const VittaApp({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<AppCubit>.value(value: G<AppCubit>()),
      BlocProvider<PremiumCubit>.value(value: G<PremiumCubit>()),
      BlocProvider<RestTimerCubit>.value(value: G<RestTimerCubit>()),
    ],
    child: BlocBuilder<AppCubit, AppSettings>(
      builder: (context, state) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => context.l10n.appTitle,
        theme: VTTheme.light,
        darkTheme: VTTheme.dark,
        themeMode: state.themeMode,
        locale: state.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: AppRouter.router,
        builder: (context, child) => LoaderOverlay(overlayWidgetBuilder: (_) => const VTLoadingOverlayIndicator(), child: child!),
      ),
    ),
  );
}
