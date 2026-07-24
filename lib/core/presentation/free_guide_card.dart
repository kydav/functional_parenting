import 'dart:async';

import 'package:flutter/material.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';
import 'package:functional_parenting/core/providers/engagement_provider.dart';
import 'package:functional_parenting/core/services/analytics_service.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Taylor's free lead-magnet landing page (LeadConnector / GoHighLevel).
/// Opting in here drops the parent into the founder's email marketing chain.
const _kFreeGuideUrl = 'https://pages.taylorthomascoaching.com/free-guide';

/// Query keys the LeadConnector form reads to pre-fill its fields. If the
/// founder's form uses different field keys, adjust these two constants.
const _kEmailParam = 'email';
const _kFirstNameParam = 'first_name';

/// ── Dismissal (persisted) ────────────────────────────────────────────────────
/// Once the parent taps the card's X, we never show it again on this device.

const _kDismissedKey = 'free_guide_dismissed';

class FreeGuideDismissedController extends StateNotifier<bool> {
  FreeGuideDismissedController(this._prefs)
    : super(_prefs.getBool(_kDismissedKey) ?? false);

  final SharedPreferences _prefs;

  Future<void> dismiss() async {
    state = true;
    await _prefs.setBool(_kDismissedKey, true);
  }
}

final freeGuideDismissedProvider =
    StateNotifierProvider<FreeGuideDismissedController, bool>(
      (ref) =>
          FreeGuideDismissedController(ref.watch(sharedPreferencesProvider)),
    );

/// ── URL + launch ─────────────────────────────────────────────────────────────

/// Builds the opt-in URL with attribution (UTM) params so app-sourced leads are
/// taggable in his CRM, plus email/first-name pre-fill pulled from Firebase Auth
/// so the parent only has to tap "download".
Uri buildFreeGuideUri({String? email, String? firstName}) {
  final base = Uri.parse(_kFreeGuideUrl);
  return base.replace(
    queryParameters: {
      ...base.queryParameters,
      'utm_source': 'app',
      'utm_medium': 'in_app',
      'utm_campaign': 'free_guide',
      if (email != null && email.isNotEmpty) _kEmailParam: email,
      if (firstName != null && firstName.isNotEmpty)
        _kFirstNameParam: firstName,
    },
  );
}

/// Opens the free-guide opt-in in an in-app browser tab (SFSafariViewController
/// on iOS, Custom Tabs on Android) so his tracking pixels and form work exactly
/// as they do on the web, while the parent stays in the app's context. Falls
/// back to the external browser if the in-app view isn't available.
Future<void> openFreeGuide(BuildContext context, WidgetRef ref) async {
  final auth = ref.read(authNotifierProvider);
  final displayName = auth.currentUser?.displayName ?? '';
  final firstName = displayName.trim().isEmpty
      ? null
      : displayName.trim().split(' ').first;
  final uri = buildFreeGuideUri(email: auth.userEmail, firstName: firstName);

  unawaited(AnalyticsService.instance.logEvent('free_guide_cta_tap'));

  try {
    final ok = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    if (ok) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open the guide. Try again.")),
      );
    }
  }
}

/// A warm, ungated CTA card inviting parents to grab Taylor's free guide.
/// Free / top-of-funnel. Dismissable via the X (persisted); callers should hide
/// it when [freeGuideDismissedProvider] is true.
class FreeGuideCard extends ConsumerWidget {
  const FreeGuideCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SoftCard(
      color: kSage.withValues(alpha: 0.35),
      onTap: () => openFreeGuide(context, ref),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Eyebrow(
                'Free guide from Taylor',
                icon: Icons.card_giftcard_rounded,
                color: kSageDeep,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: kNavy.withValues(alpha: 0.5),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                tooltip: 'Dismiss',
                onPressed: () {
                  AnalyticsService.instance.logEvent('free_guide_dismissed');
                  ref.read(freeGuideDismissedProvider.notifier).dismiss();
                },
              ),
            ],
          ),
          //const SizedBox(height: 10),
          Text(
            'The 5-Day Parent Reset',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'A short daily framework to understand why the behavior keeps '
            'happening — and respond before things escalate.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Text(
                'Get the free guide',
                style: TextStyle(
                  color: kNavy,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, color: kNavy, size: 18),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
