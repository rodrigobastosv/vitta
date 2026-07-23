import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/units/unit_system.dart';
import 'package:vitta/app/cubit/app_cubit.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/domain/settings/entities/app_settings.dart';
import 'package:vitta/app/presentation/pages/settings/widgets/settings_labels.dart';
import 'package:vitta/app/presentation/pages/settings/widgets/settings_navigation_tile.dart';
import 'package:vitta/app/presentation/pages/settings/widgets/settings_option.dart';
import 'package:vitta/app/presentation/pages/settings/widgets/settings_option_sheet.dart';
import 'package:vitta/l10n/arb/app_localizations.dart';

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
              child: SettingsNavigationTile(
                icon: Icons.dashboard_customize_outlined,
                accent: context.colorScheme.primary,
                title: l10n.settingsHomeLayoutLabel,
                subtitle: l10n.settingsHomeLayoutHint,
                onTap: () => context.pushRoute(.homeLayout),
              ),
            ),
            const VTGap.m(),
            VTAppearEffect(
              index: 1,
              child: SettingsNavigationTile(
                icon: Icons.translate,
                accent: VTColors.sleep,
                title: l10n.settingsLanguageLabel,
                subtitle: settingsLocaleLabel(state.locale, l10n),
                onTap: () => _pickLocale(context, cubit, state, l10n),
              ),
            ),
            const VTGap.m(),
            VTAppearEffect(
              index: 2,
              child: SettingsNavigationTile(
                icon: Icons.brightness_6_outlined,
                accent: VTColors.macroCarbs,
                title: l10n.settingsThemeLabel,
                subtitle: state.themeMode.label(l10n),
                onTap: () => _pickThemeMode(context, cubit, state, l10n),
              ),
            ),
            const VTGap.m(),
            VTAppearEffect(
              index: 3,
              child: SettingsNavigationTile(
                icon: Icons.straighten,
                accent: VTColors.macroFat,
                title: l10n.settingsUnitSystemLabel,
                subtitle: state.unitSystem.label(l10n),
                onTap: () => _pickUnitSystem(context, cubit, state, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLocale(BuildContext context, AppCubit cubit, AppSettings state, AppLocalizations l10n) async {
    final picked = await showSettingsOptionSheet<Locale?>(
      context,
      title: l10n.settingsLanguageLabel,
      selected: state.locale,
      options: [
        SettingsOption(label: l10n.languageSystemDefault, value: null),
        SettingsOption(label: l10n.languageEnglish, value: const Locale('en')),
        SettingsOption(label: l10n.languagePortuguese, value: const Locale('pt')),
      ],
    );
    if (picked == null) {
      return;
    }
    final locale = picked.value;
    if (locale == null) {
      cubit.useSystemLocale();
    } else {
      cubit.changeLocale(locale);
    }
  }

  Future<void> _pickThemeMode(BuildContext context, AppCubit cubit, AppSettings state, AppLocalizations l10n) async {
    final picked = await showSettingsOptionSheet<ThemeMode>(
      context,
      title: l10n.settingsThemeLabel,
      selected: state.themeMode,
      options: [for (final mode in ThemeMode.values) SettingsOption(label: mode.label(l10n), value: mode)],
    );
    if (picked != null) {
      cubit.changeThemeMode(picked.value);
    }
  }

  Future<void> _pickUnitSystem(BuildContext context, AppCubit cubit, AppSettings state, AppLocalizations l10n) async {
    final picked = await showSettingsOptionSheet<UnitSystem>(
      context,
      title: l10n.settingsUnitSystemLabel,
      selected: state.unitSystem,
      options: [for (final system in UnitSystem.values) SettingsOption(label: system.label(l10n), value: system)],
    );
    if (picked != null) {
      cubit.changeUnitSystem(picked.value);
    }
  }
}
