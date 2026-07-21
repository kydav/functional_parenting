import 'package:flutter/material.dart';
import 'package:functional_parenting/core/models/action_plan.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/toolkit_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// The one-page "Family Action Plan".
class ActionPlanViewScreen extends ConsumerWidget {
  final String planId;
  const ActionPlanViewScreen({required this.planId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(actionPlansProvider).value ?? const [];
    ActionPlan? plan;
    for (final p in plans) {
      if (p.id == planId) plan = p;
    }

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Action plan')),
        body: const Center(child: Text('Plan not found.')),
      );
    }
    final p = plan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Action Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => context.push('/tools/plans/$planId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete plan?'),
                  content: const Text("This can't be undone."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(toolkitRepositoryProvider).deletePlan(planId);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: PageBody(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.title.isEmpty ? 'Untitled plan' : p.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (p.reviewDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Review on ${DateFormat.yMMMMd().format(p.reviewDate!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            _Section(
              icon: Icons.flag_outlined,
              label: 'Behavior goal',
              value: p.goal,
            ),
            _Section(
              icon: Icons.psychology_alt_outlined,
              label: 'Possible function',
              value: p.function,
            ),
            _Section(
              icon: Icons.shield_outlined,
              label: 'Prevention',
              value: p.prevention,
            ),
            _Section(
              icon: Icons.swap_horiz_rounded,
              label: 'Replacement behavior',
              value: p.replacement,
            ),
            _Section(
              icon: Icons.star_outline_rounded,
              label: 'Reinforcement',
              value: p.reinforcement,
            ),
            _Section(
              icon: Icons.reply_rounded,
              label: 'When it happens, I will…',
              value: p.response,
            ),
            _Section(
              icon: Icons.insights_rounded,
              label: "What I'll track",
              value: p.dataToTrack,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Section({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: kBlueDeep),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isEmpty ? '—' : value,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
