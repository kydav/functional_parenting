import 'package:flutter/material.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/toolkit_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class ActionPlansScreen extends ConsumerWidget {
  const ActionPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(actionPlansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Action plans')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tools/plans/new'),
        icon: const Icon(Icons.add),
        label: const Text('Plan'),
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (plans) {
          if (plans.isEmpty) {
            return EmptyState(
              icon: Icons.description_outlined,
              title: 'Build a plan',
              message:
                  'Turn a behavior you want to change into a clear, one-page '
                  'plan you can actually follow.',
              action: FilledButton.icon(
                onPressed: () => context.push('/tools/plans/new'),
                icon: const Icon(Icons.add),
                label: const Text('New plan'),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              for (final p in plans) ...[
                SoftCard(
                  onTap: () => context.push('/tools/plans/${p.id}'),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: kBlue.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: kNavy,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title.isEmpty ? 'Untitled plan' : p.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (p.goal.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                p.goal,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (p.reviewDate != null)
                        Text(
                          'Review ${DateFormat('MMM d').format(p.reviewDate!)}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}
