import 'package:flutter/material.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

/// The running build's version, at the foot of the profile page. It is stated
/// rather than made tappable: it exists so a tester reporting a bug can say
/// which build they are on, and both release pipelines number builds
/// independently, so the version name alone does not identify one.
///
/// A platform that cannot answer renders nothing — a half-stated version is
/// worse than none, since it would name a build that does not exist.
class ProfileAppVersion extends StatelessWidget {
  const ProfileAppVersion({required this.version, required this.buildNumber, super.key});

  final String version;
  final String buildNumber;

  @override
  Widget build(BuildContext context) {
    if (version.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      context.l10n.profileAppVersion(version, buildNumber),
      textAlign: .center,
      style: VTTextStyles.caption(context).copyWith(color: context.colorScheme.onSurfaceVariant),
    );
  }
}
