import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/core/navigation/navigation_extensions.dart';
import 'package:vitta/app/core/toast/toast_extensions.dart';
import 'package:vitta/app/cubit/premium_cubit.dart';
import 'package:vitta/app/design_system/components/general/vt_appear_effect.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/auth/entities/user.dart';
import 'package:vitta/app/domain/premium/entities/premium_feature.dart';
import 'package:vitta/app/presentation/general/vt_page.dart';
import 'package:vitta/app/presentation/pages/auth/auth_cubit.dart';
import 'package:vitta/app/presentation/pages/auth/auth_presentation_event.dart';
import 'package:vitta/app/presentation/pages/auth/auth_state.dart';
import 'package:vitta/app/presentation/pages/premium/paywall_extra.dart';
import 'package:vitta/app/presentation/pages/premium/premium_state.dart';
import 'package:vitta/app/presentation/pages/premium/widgets/paywall_active_card.dart';
import 'package:vitta/app/presentation/pages/premium/widgets/paywall_feature_row.dart';
import 'package:vitta/app/presentation/pages/premium/widgets/paywall_free_card.dart';
import 'package:vitta/app/presentation/pages/premium/widgets/paywall_header.dart';
import 'package:vitta/app/presentation/pages/premium/widgets/paywall_legal_footer.dart';
import 'package:vitta/app/presentation/pages/premium/widgets/paywall_purchase_section.dart';

// Hangs off AuthCubit because whether to show a purchase CTA or a sign-up CTA is
// a question about the user; the entitlement itself comes from the root
// PremiumCubit, which every locked affordance in the app reads too.
class PaywallPage extends StatelessWidget {
  const PaywallPage({this.extra, super.key});

  final PaywallExtra? extra;

  @override
  Widget build(BuildContext context) => VTPage<AuthCubit, AuthState, AuthPresentationEvent>(
    onPresentation: (context, event) {
      switch (event) {
        case AuthShowLoading():
          context.showLoading();
        case AuthHideLoading():
          context.hideLoading();
        case AuthActionFailed(:final message):
          context.showErrorToast(message: message);
        case AuthSignedIn():
        case AuthProfileUpdated():
        case AuthAccountDeleted():
          break;
      }
    },
    builder: (context, authCubit, authState) {
      final l10n = context.l10n;
      final colorScheme = context.colorScheme;
      return Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<PremiumCubit, PremiumState>(
          builder: (context, premiumState) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(VTSpacing.l),
              child: VTAppearEffect(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    const PaywallHeader(),
                    const VTGap.l(),
                    Text(l10n.premiumIntro, style: VTTextStyles.body(context).copyWith(color: colorScheme.onSurfaceVariant)),
                    const VTGap.xl(),
                    Text(l10n.premiumFeaturesTitle, style: VTTextStyles.title(context)),
                    const VTGap.m(),
                    for (final feature in PremiumFeature.values) ...[
                      PaywallFeatureRow(feature: feature, isHighlighted: feature == extra?.highlightedFeature),
                      const VTGap.l(),
                    ],
                    const PaywallFreeCard(),
                    const VTGap.xl(),
                    if (premiumState.isPremium)
                      PaywallActiveCard(expiresAt: premiumState.status.expiresAt)
                    else
                      PaywallPurchaseSection(
                        isSignedIn: authState.user is AuthenticatedUser,
                        offer: premiumState.offer,
                        onSignUp: () => _signUp(context, authCubit),
                        onSubscribe: () => _subscribe(context, authState.user),
                        onRestore: () => _restore(context, authState.user),
                      ),
                    const VTGap.l(),
                    const PaywallLegalFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  Future<void> _subscribe(BuildContext context, User user) async {
    if (user is! AuthenticatedUser) {
      return;
    }
    final premiumCubit = context.read<PremiumCubit>();
    final l10n = context.l10n;
    context.showLoading();
    try {
      final hasPurchased = await premiumCubit.purchase(userId: user.id);
      if (!context.mounted) {
        return;
      }
      context.hideLoading();
      // Cancelling is a deliberate action, not a failure: it reports false and
      // says nothing at all.
      if (hasPurchased) {
        context.showToast(title: l10n.premiumPurchasedTitle, message: l10n.premiumPurchasedMessage);
      }
    } on Exception {
      if (context.mounted) {
        context.hideLoading();
        context.showErrorToast(message: l10n.premiumPurchaseFailed);
      }
    }
  }

  Future<void> _restore(BuildContext context, User user) async {
    if (user is! AuthenticatedUser) {
      return;
    }
    final premiumCubit = context.read<PremiumCubit>();
    final l10n = context.l10n;
    context.showLoading();
    try {
      final hasRestored = await premiumCubit.restore(userId: user.id);
      if (!context.mounted) {
        return;
      }
      context.hideLoading();
      if (hasRestored) {
        context.showToast(title: l10n.premiumRestoredTitle, message: l10n.premiumRestoredMessage);
      } else {
        context.showWarningToast(message: l10n.premiumNothingToRestore);
      }
    } on Exception {
      if (context.mounted) {
        context.hideLoading();
        context.showErrorToast(message: l10n.premiumPurchaseFailed);
      }
    }
  }

  Future<void> _signUp(BuildContext context, AuthCubit authCubit) async {
    final premiumCubit = context.read<PremiumCubit>();
    await context.pushRoute(.signUp);
    authCubit.refreshUser();
    await premiumCubit.refresh();
  }
}
