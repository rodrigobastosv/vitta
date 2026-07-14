import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_colors.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.onAction, this.email, super.key});

  final String? email;
  final VoidCallback onAction;

  bool get _isSignedIn => email != null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = _isSignedIn ? email! : l10n.profileGuestTitle;
    final initial = (email?.isNotEmpty ?? false) ? email![0].toUpperCase() : null;
    return Container(
      padding: const EdgeInsets.all(VTSpacing.l),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: .topLeft, end: .bottomRight, colors: [VTColors.green, VTColors.greenLight]),
        borderRadius: VTRadius.borderRadiusL,
        boxShadow: [BoxShadow(color: VTColors.green.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: VTColors.onGreen,
                child: initial != null
                    ? Text(initial, style: VTTextStyles.headline(context).copyWith(color: VTColors.green))
                    : const Icon(Icons.person_outline, color: VTColors.green, size: 30),
              ),
              const VTGap.m(),
              Expanded(
                child: Text(
                  title,
                  style: VTTextStyles.title(context).copyWith(color: VTColors.onGreen),
                  maxLines: 1,
                  overflow: .ellipsis,
                ),
              ),
            ],
          ),
          if (!_isSignedIn) ...[
            const VTGap.m(),
            Text(
              l10n.authAnonymousMessage,
              style: VTTextStyles.caption(context).copyWith(color: VTColors.onGreen.withValues(alpha: 0.85)),
            ),
          ],
          const VTGap.l(),
          SizedBox(
            width: double.infinity,
            child: _isSignedIn
                ? OutlinedButton(
                    onPressed: onAction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: VTColors.onGreen,
                      side: BorderSide(color: VTColors.onGreen.withValues(alpha: 0.6)),
                    ),
                    child: Text(l10n.authLogoutAction),
                  )
                : FilledButton(
                    onPressed: onAction,
                    style: FilledButton.styleFrom(backgroundColor: VTColors.onGreen, foregroundColor: VTColors.green),
                    child: Text(l10n.profileSignInAction),
                  ),
          ),
        ],
      ),
    );
  }
}
