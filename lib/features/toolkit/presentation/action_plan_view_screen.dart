import 'package:flutter/material.dart';
import 'package:functional_parenting/core/models/action_plan.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/toolkit_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// The one-page "Functional Parenting Action Plan" — one behavior across the
/// five phases.
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
        title: const Text('Action Plan'),
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
            const Eyebrow('The behavior'),
            const SizedBox(height: 6),
            Text(
              p.title.isEmpty ? 'Untitled plan' : p.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            _Phase(
              number: 1,
              phase: 'Reset the Parent',
              label: 'The reaction I’ll practice',
              value: p.resetPlan,
            ),
            _Phase(
              number: 2,
              phase: 'Define the Goal',
              label: 'The skill I want to build',
              value: p.goal,
            ),
            _Phase(
              number: 3,
              phase: 'Identify the Function',
              label: 'What the behavior is for',
              value: p.function,
            ),
            _Phase(
              number: 4,
              phase: 'Build the Structure',
              label: 'The structure I’ll add',
              value: p.structure,
            ),
            _Phase(
              number: 5,
              phase: 'Respond With Purpose',
              label: 'My intentional response',
              value: p.response,
            ),
          ],
        ),
      ),
    );
  }
}

class _Phase extends StatelessWidget {
  final int number;
  final String phase;
  final String label;
  final String value;
  const _Phase({
    required this.number,
    required this.phase,
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
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kBlue.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$number',
                style: const TextStyle(
                  color: kNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phase,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
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
