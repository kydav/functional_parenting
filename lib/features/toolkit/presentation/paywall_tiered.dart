import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/constants.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/pro_provider.dart';
import 'package:functional_parenting/core/providers/purchase_provider.dart';
import 'package:functional_parenting/core/services/analytics_service.dart';
import 'package:functional_parenting/core/services/purchase_service.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Copy for the free-trial badge. Must match the introductory-offer length you
/// configure on the subscriptions in App Store Connect / Play.
const _kTrialCopy = '2-week free trial';

/// Tiered paywall — monthly / yearly / lifetime, all unlocking the same
/// `Functional Parenting Pro` entitlement. Shown by default; PaywallScreen
/// falls back to the legacy one-time view via the Remote Config kill-switch.
class TieredPaywallView extends HookConsumerWidget {
  const TieredPaywallView({super.key});

  static const _valueProps = [
    (
      icon: Icons.calendar_today_rounded,
      title: 'A full year of daily content',
      body:
          '365 tips, challenges, and reflections — not the same handful on '
          'repeat.',
    ),
    (
      icon: Icons.alt_route_rounded,
      title: 'Full “What should I do?” responses',
      body: 'The complete in-the-moment guidance for every situation.',
    ),
    (
      icon: Icons.checklist_rounded,
      title: 'Behavior Tracker (ABC)',
      body: 'Log antecedent, behavior, and consequence to reveal patterns.',
    ),
    (
      icon: Icons.description_outlined,
      title: 'Parenting Plan builder',
      body: 'Turn a goal into a clear one-page plan you can follow.',
    ),
    (
      icon: Icons.workspace_premium_outlined,
      title: 'All four guided worksheets + function guide',
      body:
          'Work the framework phase by phase, with a plain-language reference.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proProvider);
    // valueOrNull: if the store is unavailable the offerings future errors —
    // .value would rethrow and crash the paywall. Empty just means "no prices
    // to show yet".
    final packages = ref.watch(proPackagesProvider).valueOrNull ?? const [];
    final selected = useState<Package?>(null);
    final busy = useState(false);

    useEffect(() {
      AnalyticsService.instance.track('paywall_viewed');
      return null;
    }, const []);

    // Default the selection to the annual tier (the value pick) when nothing is
    // chosen yet, falling back to the first available package.
    Package? effective = selected.value;
    if (effective == null && packages.isNotEmpty) {
      effective = packages.firstWhere(
        (p) => p.packageType == PackageType.annual,
        orElse: () => packages.first,
      );
    }

    void snack(String msg) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));

    Future<void> purchase() async {
      AnalyticsService.instance.track('toolkit_unlock_tapped');
      if (!PurchaseService.instance.isConfigured) {
        snack('Purchases are being set up — available very soon.');
        return;
      }
      final pkg = effective;
      if (pkg == null) {
        snack("Plans aren't available to buy just yet.");
        return;
      }
      busy.value = true;
      try {
        final result = await Purchases.purchase(PurchaseParams.package(pkg));
        if (!context.mounted) return;
        if (PurchaseService.instance.entitlementActive(result.customerInfo)) {
          AnalyticsService.instance.track('toolkit_unlocked');
          snack("You're all set — everything's unlocked.");
          context.pop();
        }
      } on PlatformException catch (e) {
        final code = PurchasesErrorHelper.getErrorCode(e);
        if (code != PurchasesErrorCode.purchaseCancelledError &&
            context.mounted) {
          snack("Purchase couldn't complete. Please try again.");
        }
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    Future<void> restore() async {
      if (!PurchaseService.instance.isConfigured) {
        snack('Restore will be available with purchases.');
        return;
      }
      busy.value = true;
      try {
        final info = await Purchases.restorePurchases();
        if (!context.mounted) return;
        if (PurchaseService.instance.entitlementActive(info)) {
          AnalyticsService.instance.track('purchase_restored');
          snack('Purchase restored — welcome back.');
          context.pop();
        } else {
          snack('No previous purchase found on this account.');
        }
      } on PlatformException {
        if (context.mounted) snack('Couldn’t restore right now.');
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: PageBody(
              showTrack: true,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SoftCard(
                    color: context.colors.brandFill,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Eyebrow(
                          isPro ? 'You own this' : 'Functional Parenting Pro',
                          icon: Icons.workspace_premium_outlined,
                          color: kSage,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Everything you need to move from “what do I do?” to '
                          'a plan you can follow.',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SoftCard(
                    child: Column(
                      children: [
                        for (final v in _valueProps) ...[
                          if (v != _valueProps.first)
                            const SizedBox(height: 16),
                          _ValueRow(icon: v.icon, title: v.title, body: v.body),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(top: BorderSide(color: context.colors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: isPro
                    ? FilledButton(
                        onPressed: () => context.go('/tools'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: const Text('Open the Toolkit'),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (packages.isEmpty)
                            Text(
                              'Plans are being set up — check back very soon.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                            )
                          else
                            for (final p in packages) ...[
                              _TierCard(
                                package: p,
                                selected: p.identifier == effective?.identifier,
                                onTap: () => selected.value = p,
                              ),
                              const SizedBox(height: 12),
                            ],
                          FilledButton(
                            onPressed: busy.value ? null : purchase,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                            child: busy.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(_ctaLabel(effective)),
                          ),
                          TextButton(
                            onPressed: busy.value ? null : restore,
                            child: const Text('Restore purchase'),
                          ),
                          const _LegalFootnote(),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

bool _hasFreeTrial(Package p) {
  final intro = p.storeProduct.introductoryPrice;
  return intro != null && intro.price == 0;
}

String _tierTitle(Package p) => switch (p.packageType) {
  PackageType.monthly => 'Monthly',
  PackageType.annual => 'Yearly',
  PackageType.lifetime => 'Lifetime',
  _ => p.storeProduct.title,
};

String _tierSubtitle(Package p) => switch (p.packageType) {
  PackageType.monthly => 'Billed monthly ',
  PackageType.annual => 'Billed yearly ',
  PackageType.lifetime => 'One-time · yours forever',
  _ => '',
};

String _ctaLabel(Package? p) {
  if (p == null) return 'Continue';
  if (_hasFreeTrial(p)) return 'Start free trial';
  if (p.packageType == PackageType.lifetime) return 'Unlock Lifetime';
  return 'Subscribe';
}

/// A compact value row: tinted icon, title, one-line description.
class _ValueRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _ValueRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: kBlue.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: kNavy, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                body,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A selectable pricing tier: title, price, subtitle, optional "best value" and
/// free-trial badges, with a selected/unselected border + radio affordance.
class _TierCard extends StatelessWidget {
  final Package package;
  final bool selected;
  final VoidCallback onTap;
  const _TierCard({
    required this.package,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAnnual = package.packageType == PackageType.annual;
    final trial = _hasFreeTrial(package);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : context.colors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : context.colors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _tierTitle(package),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (isAnnual) ...[
                        const SizedBox(width: 8),
                        const _Badge('BEST VALUE'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trial
                        ? '$_kTrialCopy, then ${_tierSubtitle(package).toLowerCase()}'
                        : _tierSubtitle(package),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              package.packageType == PackageType.lifetime
                  ? '\$49.99'
                  : package.storeProduct.priceString,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: kSage,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: kNavy,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _LegalFootnote extends StatelessWidget {
  const _LegalFootnote();

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: context.colors.textSecondary,
      fontSize: 11,
      height: 1.4,
    );
    final link = muted?.copyWith(
      decoration: TextDecoration.underline,
      color: kNavy,
    );
    void open(String url) =>
        launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);

    return Column(
      children: [
        Text(
          'Subscriptions auto-renew unless canceled at least 24 hours before '
          'the period ends. Manage or cancel anytime in your store account '
          'settings. Lifetime is a one-time purchase.',
          textAlign: TextAlign.center,
          style: muted,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => open(kTermsUrl),
              child: Text('Terms', style: link),
            ),
            Text('   ·   ', style: muted),
            GestureDetector(
              onTap: () => open(kPrivacyUrl),
              child: Text('Privacy', style: link),
            ),
          ],
        ),
      ],
    );
  }
}
