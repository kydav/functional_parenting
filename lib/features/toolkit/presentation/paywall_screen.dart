import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/pro_provider.dart';
import 'package:functional_parenting/core/providers/purchase_provider.dart';
import 'package:functional_parenting/core/services/purchase_service.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:functional_parenting/features/tools/presentation/worksheets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends HookConsumerWidget {
  const PaywallScreen({super.key});

  /// The ongoing tools you return to as you put the framework into practice.
  /// (The four guided phase worksheets are pulled from [kWorksheets].)
  static const _ongoing = [
    (
      icon: Icons.checklist_rounded,
      title: 'ABC Behavior Tracker',
      body:
          "Log antecedent, behavior, and consequence over time to see what's really driving the behavior.",
    ),
    (
      icon: Icons.description_outlined,
      title: 'Family Action Plan builder',
      body:
          'Turn a behavior goal into a clear, one-page plan: prevention, replacement behavior, reinforcement, and response.',
    ),
    (
      icon: Icons.menu_book_rounded,
      title: 'Behavior-function guide',
      body:
          'A plain-language reference for the four functions behind behavior.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proProvider);
    final package = ref.watch(proPackageProvider).value;
    final busy = useState(false);

    void snack(String msg) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));

    Future<void> unlock() async {
      if (!PurchaseService.instance.isConfigured) {
        snack('Purchases are being set up — available very soon.');
        return;
      }
      final pkg = package;
      if (pkg == null) {
        snack('The toolkit isn’t available to buy just yet.');
        return;
      }
      busy.value = true;
      try {
        final info = await Purchases.purchasePackage(pkg);
        if (!context.mounted) return;
        if (PurchaseService.instance.entitlementActive(info)) {
          snack('You’re all set — the toolkit is unlocked.');
          context.pop();
        }
      } on PlatformException catch (e) {
        final code = PurchasesErrorHelper.getErrorCode(e);
        if (code != PurchasesErrorCode.purchaseCancelledError &&
            context.mounted) {
          snack('Purchase couldn’t complete. Please try again.');
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
      body: PageBody(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
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
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Everything you need to move from "what do I do?" to a plan '
                    'you can actually follow — the full framework, guided '
                    'worksheets, and the tools to keep going. Yours to keep, '
                    'no subscription.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Group 1 — the four guided phase worksheets.
            Text(
              'Work the framework',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Guided worksheets that walk you through all four phases of the '
              'Functional Parenting Framework, one step at a time.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              child: Column(
                children: [
                  for (final w in kWorksheets) ...[
                    if (w.id != kWorksheets.first.id) ...[
                      const SizedBox(height: 14),
                      Divider(height: 1, color: context.colors.border),
                      const SizedBox(height: 14),
                    ],
                    _PhaseRow(
                      icon: w.icon,
                      phase: w.phaseEyebrow,
                      title: w.title,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Group 2 — the ongoing tools.
            Text(
              'Ongoing toolkit',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Tools you return to as you put the framework into practice.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            for (final f in _ongoing) ...[
              _FeatureCard(icon: f.icon, title: f.title, body: f.body),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            if (isPro)
              FilledButton(
                onPressed: () => context.go('/tools'),
                child: const Text('Open the Toolkit'),
              )
            else ...[
              Align(
                child: FilledButton(
                  onPressed: busy.value ? null : unlock,
                  child: busy.value
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
              ),
              const SizedBox(height: 8),
              Align(
                child: TextButton(
                  onPressed: busy.value ? null : restore,
                  child: const Text('Restore purchase'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A full feature card: tinted icon tile, title, and a descriptive body.
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kBlue.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kNavy, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact row inside the framework card: icon, phase label, worksheet title.
class _PhaseRow extends StatelessWidget {
  final IconData icon;
  final String phase;
  final String title;
  const _PhaseRow({
    required this.icon,
    required this.phase,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: kBlue.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: kNavy, size: 19),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                phase.toUpperCase(),
                style: const TextStyle(
                  color: kBlueDeep,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.9,
                ),
              ),
              const SizedBox(height: 2),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}
