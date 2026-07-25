import 'package:flutter/material.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/toolkit_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// The parent's saved "What should I do?" recommendations. Tapping one re-opens
/// it in the decision tool (respecting current Pro status).
class SavedRecommendationsScreen extends ConsumerWidget {
  const SavedRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedRecommendationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved recommendations')),
      body: savedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (saved) {
          if (saved.isEmpty) {
            return EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'Nothing saved yet',
              message:
                  'When a recommendation from "What should I do?" is helpful, '
                  'tap Save to keep it here for later.',
              action: FilledButton.icon(
                onPressed: () => context.go('/tools/decide'),
                icon: const Icon(Icons.alt_route_rounded, size: 18),
                label: const Text('Open the tool'),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              for (final r in saved) ...[
                SoftCard(
                  onTap: () =>
                      context.push('/tools/recommendation/${r.leafId}'),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: kBlue.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bookmark_rounded, color: kNavy),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.category,
                              style: const TextStyle(
                                color: kBlueDeep,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.9,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              r.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: context.colors.textSecondary,
                          size: 20,
                        ),
                        tooltip: 'Remove',
                        onPressed: () => ref
                            .read(toolkitRepositoryProvider)
                            .deleteRecommendation(r.leafId),
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
