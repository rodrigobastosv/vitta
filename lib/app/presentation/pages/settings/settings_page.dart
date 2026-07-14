import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AppCubit>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: BlocBuilder<AppCubit, AppSettings>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.symmetric(vertical: VTSpacing.s),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
              child: Text(l10n.settingsLanguageLabel, style: VTTextStyles.title(context)),
            ),
            const VTGap.s(),
            RadioGroup<Locale?>(
              groupValue: state.locale,
              onChanged: (locale) => locale == null ? cubit.useSystemLocale() : cubit.changeLocale(locale),
              child: Column(
                children: [
                  RadioListTile<Locale?>(title: Text(l10n.languageSystemDefault), value: null),
                  RadioListTile<Locale?>(title: Text(l10n.languageEnglish), value: const Locale('en')),
                  RadioListTile<Locale?>(title: Text(l10n.languagePortuguese), value: const Locale('pt')),
                ],
              ),
            ),
            const VTGap.m(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
              child: Text(l10n.settingsThemeLabel, style: VTTextStyles.title(context)),
            ),
            const VTGap.s(),
            RadioGroup<ThemeMode>(
              groupValue: state.themeMode,
              onChanged: (themeMode) => cubit.changeThemeMode(themeMode!),
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(title: Text(l10n.themeSystemDefault), value: .system),
                  RadioListTile<ThemeMode>(title: Text(l10n.themeLight), value: .light),
                  RadioListTile<ThemeMode>(title: Text(l10n.themeDark), value: .dark),
                ],
              ),
            ),
            const VTGap.m(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: VTSpacing.m),
              child: Text(l10n.settingsUnitSystemLabel, style: VTTextStyles.title(context)),
            ),
            const VTGap.s(),
            RadioGroup<UnitSystem>(
              groupValue: state.unitSystem,
              onChanged: (unitSystem) => cubit.changeUnitSystem(unitSystem!),
              child: Column(
                children: [
                  RadioListTile<UnitSystem>(title: Text(l10n.unitSystemMetric), value: .metric),
                  RadioListTile<UnitSystem>(title: Text(l10n.unitSystemImperial), value: .imperial),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
