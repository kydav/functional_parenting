import 'package:flutter/material.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  static const _included = [
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
  Widget build(BuildContext context) {
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
                  const Eyebrow(
                    'One-time purchase',
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
                    'Everything you need to move from "what do I do?" to a plan you can actually follow. Yours to keep — no subscription.',
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
            Text(
              "What's included",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            for (final f in _included) ...[
              SoftCard(
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
                      child: Icon(f.icon, color: kNavy, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            f.body,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Purchases are being set up — available very soon.',
                  ),
                ),
              ),
              child: const Text('Unlock the Toolkit'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Restore will be available with purchases.'),
                ),
              ),
              child: const Text('Restore purchase'),
            ),
          ],
        ),
      ),
    );
  }
}
