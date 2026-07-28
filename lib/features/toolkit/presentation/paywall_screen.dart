import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/pro_provider.dart';
import 'package:functional_parenting/core/providers/purchase_provider.dart';
import 'package:functional_parenting/core/services/analytics_service.dart';
import 'package:functional_parenting/core/services/purchase_service.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:functional_parenting/features/tools/presentation/worksheets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends HookConsumerWidget {
  const PaywallScreen({super.key});

  /// The ongoing tools you return to as you put the framework into practice.
  /// (The four guided phase worksheets are pulled from [kWorksheets].) Bodies
  /// are kept to a single punchy line so the whole list stays compact.
  static const _ongoing = [
    (
      icon: Icons.calendar_today_rounded,
      title: 'A full year of daily content',
      body:
          'A fresh tip, challenge, and reflection for every day — 365 of each, '
          'instead of the same handful on repeat.',
    ),
    (
      icon: Icons.alt_route_rounded,
      title: 'Full “What should I do?” response',
      body:
          'The complete in-the-moment response for every situation — what to '
          'do, what to say, and what to avoid.',
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
      icon: Icons.menu_book_rounded,
      title: 'Behavior-function guide',
      body: 'Plain-language reference for the four functions behind behavior.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proProvider);
    // valueOrNull (not .value): when the store is unavailable (no Play billing,
    // restricted account, region), the offerings future errors — .value would
    // rethrow and crash the paywall. Null just means "no price to show yet".
    final package = ref.watch(proPackageProvider).valueOrNull;
    final busy = useState(false);

    useEffect(() {
      AnalyticsService.instance.track('paywall_viewed');
      return null;
    }, const []);

    void snack(String msg) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));

    Future<void> unlock() async {
      AnalyticsService.instance.track('toolkit_unlock_tapped');
      if (!PurchaseService.instance.isConfigured) {
        snack('Purchases are being set up — available very soon.');
        return;
      }
      final pkg = package;
      if (pkg == null) {
        snack("The toolkit isn't available to buy just yet.");
        return;
      }
      busy.value = true;
      try {
        final info = await Purchases.purchasePackage(pkg);
        if (!context.mounted) return;
        if (PurchaseService.instance.entitlementActive(info)) {
          AnalyticsService.instance.track('toolkit_unlocked');
          snack("You're all set — the toolkit is unlocked.");
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

    final priceLabel = package?.storeProduct.priceString;

    return Scaffold(
      appBar: AppBar(title: const Text('Starter Toolkit')),
      // Scrollable value content + a pinned CTA footer so the purchase button
      // is always visible, no matter how far the list scrolls.
      body: Column(
        children: [
          Expanded(
            child: PageBody(
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
                          isPro ? 'You own this' : 'One-time purchase',
                          icon: Icons.workspace_premium_outlined,
                          color: kSage,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'The Functional Parenting Toolkit',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'The full framework, guided worksheets, and the '
                          'tools to keep going — everything you need to move '
                          'from "what do I do?" to a plan you can follow. '
                          'Yours to keep, no subscription.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Group 1 — the four guided phase worksheets.
                  const _GroupLabel(
                    'Work the framework',
                    'Guided worksheets through all four phases, step by step.',
                  ),
                  const SizedBox(height: 10),
                  SoftCard(
                    child: Column(
                      children: [
                        for (final w in kWorksheets) ...[
                          if (w.id != kWorksheets.first.id)
                            const SizedBox(height: 16),
                          _ItemRow(
                            icon: w.icon,
                            overline: w.phaseEyebrow,
                            title: w.title,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Group 2 — the ongoing tools.
                  const _GroupLabel(
                    'Ongoing toolkit',
                    'Tools you return to as you put the framework into '
                        'practice.',
                  ),
                  const SizedBox(height: 10),
                  SoftCard(
                    child: Column(
                      children: [
                        for (final f in _ongoing) ...[
                          if (f != _ongoing.first) const SizedBox(height: 16),
                          _ItemRow(
                            icon: f.icon,
                            title: f.title,
                            subtitle: f.body,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _PurchaseFooter(
            isPro: isPro,
            busy: busy.value,
            priceLabel: priceLabel,
            onUnlock: unlock,
            onRestore: restore,
          ),
        ],
      ),
    );
  }
}

/// A group heading: bold title + a single muted line of context.
class _GroupLabel extends StatelessWidget {
  final String title;
  final String subtitle;
  const _GroupLabel(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
        ),
      ],
    );
  }
}

/// A compact value row: tinted icon, optional overline (phase), title, and an
/// optional one-line description.
class _ItemRow extends StatelessWidget {
  final IconData icon;
  final String? overline;
  final String title;
  final String? subtitle;
  const _ItemRow({
    required this.icon,
    required this.title,
    this.overline,
    this.subtitle,
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
              if (overline != null) ...[
                Text(
                  overline!.toUpperCase(),
                  style: const TextStyle(
                    color: kBlueDeep,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Pinned bottom bar holding the price + primary action, so the CTA never
/// scrolls out of reach.
class _PurchaseFooter extends StatelessWidget {
  final bool isPro;
  final bool busy;
  final String? priceLabel;
  final VoidCallback onUnlock;
  final VoidCallback onRestore;
  const _PurchaseFooter({
    required this.isPro,
    required this.busy,
    required this.priceLabel,
    required this.onUnlock,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
                    FilledButton(
                      onPressed: busy ? null : onUnlock,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              priceLabel == null
                                  ? 'Unlock the Toolkit'
                                  : 'Unlock the Toolkit · $priceLabel',
                            ),
                    ),
                    TextButton(
                      onPressed: busy ? null : onRestore,
                      child: const Text('Restore purchase'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
