import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/presentation/pages/settings/widgets/settings_option_tile.dart';
import 'package:vitta/app/presentation/pages/settings/widgets/settings_section.dart';

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
          padding: const EdgeInsets.all(VTSpacing.m),
          children: [
            VTAppearEffect(
              child: SettingsSection(
                icon: Icons.translate,
                title: l10n.settingsLanguageLabel,
                children: [
                  SettingsOptionTile(
                    label: l10n.languageSystemDefault,
                    isSelected: state.locale == null,
                    onSelected: cubit.useSystemLocale,
                  ),
                  SettingsOptionTile(
                    label: l10n.languageEnglish,
                    isSelected: state.locale == const Locale('en'),
                    onSelected: () => cubit.changeLocale(const Locale('en')),
                  ),
                  SettingsOptionTile(
                    label: l10n.languagePortuguese,
                    isSelected: state.locale == const Locale('pt'),
                    onSelected: () => cubit.changeLocale(const Locale('pt')),
                  ),
                ],
              ),
            ),
            const VTGap.m(),
            VTAppearEffect(
              index: 1,
              child: SettingsSection(
                icon: Icons.brightness_6_outlined,
                title: l10n.settingsThemeLabel,
                children: [
                  SettingsOptionTile(
                    label: l10n.themeSystemDefault,
                    isSelected: state.themeMode == ThemeMode.system,
                    onSelected: () => cubit.changeThemeMode(ThemeMode.system),
                  ),
                  SettingsOptionTile(
                    label: l10n.themeLight,
                    isSelected: state.themeMode == ThemeMode.light,
                    onSelected: () => cubit.changeThemeMode(ThemeMode.light),
                  ),
                  SettingsOptionTile(
                    label: l10n.themeDark,
                    isSelected: state.themeMode == ThemeMode.dark,
                    onSelected: () => cubit.changeThemeMode(ThemeMode.dark),
                  ),
                ],
              ),
            ),
            const VTGap.m(),
            VTAppearEffect(
              index: 2,
              child: SettingsSection(
                icon: Icons.straighten,
                title: l10n.settingsUnitSystemLabel,
                children: [
                  SettingsOptionTile(
                    label: l10n.unitSystemMetric,
                    isSelected: state.unitSystem == UnitSystem.metric,
                    onSelected: () => cubit.changeUnitSystem(UnitSystem.metric),
                  ),
                  SettingsOptionTile(
                    label: l10n.unitSystemImperial,
                    isSelected: state.unitSystem == UnitSystem.imperial,
                    onSelected: () => cubit.changeUnitSystem(UnitSystem.imperial),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
