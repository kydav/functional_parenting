import 'package:flutter/material.dart';
import 'package:functional_parenting/core/models/behavior_log.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/toolkit_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class BehaviorTrackerScreen extends ConsumerWidget {
  const BehaviorTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(behaviorLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Behavior tracker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tools/tracker/new'),
        icon: const Icon(Icons.add),
        label: const Text('Log'),
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) {
          if (logs.isEmpty) {
            return EmptyState(
              icon: Icons.checklist_rounded,
              title: 'Start tracking',
              message:
                  'Log a behavior right after it happens — the antecedent, '
                  'the behavior, and what followed. Patterns show up over time.',
              action: FilledButton.icon(
                onPressed: () => context.push('/tools/tracker/new'),
                icon: const Icon(Icons.add),
                label: const Text('Add first log'),
              ),
            );
          }
          final grouped = <String, List<BehaviorLog>>{};
          for (final l in logs) {
            grouped.putIfAbsent(_dayLabel(l.occurredAt), () => []).add(l);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              for (final entry in grouped.entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 0, 8),
                  child: Text(
                    entry.key,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                for (final log in entry.value) ...[
                  _LogCard(log: log),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(d);
  }
}

class _LogCard extends StatelessWidget {
  final BehaviorLog log;
  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: () => context.push('/tools/tracker/${log.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  log.behavior,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                DateFormat('h:mm a').format(log.occurredAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          if (log.setting.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(log.setting, style: Theme.of(context).textTheme.bodySmall),
          ],
          if (log.antecedent.isNotEmpty || log.consequence.isNotEmpty) ...[
            const SizedBox(height: 8),
            _AbcRow(a: log.antecedent, b: log.behavior, c: log.consequence),
          ],
        ],
      ),
    );
  }
}

class _AbcRow extends StatelessWidget {
  final String a;
  final String b;
  final String c;
  const _AbcRow({required this.a, required this.b, required this.c});

  @override
  Widget build(BuildContext context) {
    Widget chip(String letter, String text, Color color) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            letter,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            text.isEmpty ? '—' : text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          chip('BEFORE', a, kBlueDeep),
          const SizedBox(width: 8),
          chip('BEHAVIOR', b, kSageDeep),
          const SizedBox(width: 8),
          chip('AFTER', c, kSuccessGreen),
        ],
      ),
    );
  }
}
