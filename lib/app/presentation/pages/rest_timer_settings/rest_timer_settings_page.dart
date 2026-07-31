import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/cubit/rest_timer_cubit.dart';
import 'package:vitta/app/cubit/rest_timer_state.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/presentation/pages/rest_timer_settings/widgets/rest_length_card.dart';
import 'package:vitta/app/presentation/pages/rest_timer_settings/widgets/rest_sound_card.dart';

class RestTimerSettingsPage extends StatelessWidget {
  const RestTimerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<RestTimerCubit>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsRestTimerLabel)),
      body: BlocBuilder<RestTimerCubit, RestTimerState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.all(VTSpacing.m),
          children: [
            VTAppearEffect(child: RestLengthCard(rest: state.configured, onChanged: cubit.changeRest)),
            const VTGap.m(),
            VTAppearEffect(
              index: 1,
              child: RestSoundCard(isEnabled: state.isSoundEnabled, onChanged: (isEnabled) => cubit.changeSoundEnabled(isEnabled: isEnabled)),
            ),
          ],
        ),
      ),
    );
  }
}
