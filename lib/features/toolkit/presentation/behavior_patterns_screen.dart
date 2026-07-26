import 'package:flutter/material.dart';
import 'package:functional_parenting/core/models/behavior_log.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/toolkit_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:functional_parenting/features/toolkit/presentation/behavior_log_options.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Aggregates the tracker logs into a per-behavior function breakdown. Only the
/// consequence carries the function, so each selected consequence adds one
/// point to its function for that behavior.
class BehaviorPatternsScreen extends ConsumerWidget {
  const BehaviorPatternsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(behaviorLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Possible Functions or Why Behind the Behavior'),
        titleTextStyle: Theme.of(context).textTheme.titleMedium,
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) {
          final byBehavior = _aggregate(logs);
          if (byBehavior.isEmpty) {
            return const EmptyState(
              icon: Icons.bar_chart_rounded,
              title: 'No patterns yet',
              message:
                  'Log a few behaviors — with what happened right after — and '
                  'the possible functions will build here for each behavior.',
            );
          }
          final behaviors = byBehavior.keys.toList()
            ..sort(
              (a, b) => byBehavior[b]!.total.compareTo(byBehavior[a]!.total),
            );
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              const _Disclaimer(),
              const SizedBox(height: 8),
              for (final behavior in behaviors) ...[
                _BehaviorChart(
                  behavior: behavior,
                  tally: byBehavior[behavior]!,
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  /// behavior → function tally. Skips logs with no behavior or no mapped
  /// consequence.
  Map<String, _Tally> _aggregate(List<BehaviorLog> logs) {
    final out = <String, _Tally>{};
    for (final log in logs) {
      if (log.behavior.isEmpty) continue;
      final tally = out.putIfAbsent(log.behavior, _Tally.new);
      var counted = false;
      for (final consequence in log.consequence) {
        final fn = kConsequenceFunctions[consequence];
        if (fn == null) continue;
        tally.points[fn] = (tally.points[fn] ?? 0) + 1;
        counted = true;
      }
      if (counted) tally.entries += 1;
    }
    // Drop behaviors that never produced a single function point.
    out.removeWhere((_, t) => t.total == 0);
    return out;
  }
}

class _Tally {
  final Map<String, int> points = {};
  int entries = 0;
  int get total => points.values.fold(0, (a, b) => a + b);
}

class _BehaviorChart extends StatelessWidget {
  final String behavior;
  final _Tally tally;
  const _BehaviorChart({required this.behavior, required this.tally});

  @override
  Widget build(BuildContext context) {
    final maxPoints = tally.points.values.fold(0, (a, b) => a > b ? a : b);
    final top = tally.points.entries
        .where((e) => e.value == maxPoints)
        .map((e) => e.key)
        .toSet();

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(behavior, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            '${tally.entries} ${tally.entries == 1 ? 'entry' : 'entries'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          for (final fn in kTrackerFunctions) ...[
            _FunctionBar(
              label: fn,
              points: tally.points[fn] ?? 0,
              max: maxPoints,
              highlight: top.contains(fn) && maxPoints > 0,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _FunctionBar extends StatelessWidget {
  final String label;
  final int points;
  final int max;
  final bool highlight;
  const _FunctionBar({
    required this.label,
    required this.points,
    required this.max,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: max == 0 ? 0 : points / max,
              minHeight: 10,
              backgroundColor: context.colors.border,
              color: highlight ? kBlueDeep : kBlue,
            ),
          ),
        ),
        SizedBox(
          width: 26,
          child: Text(
            '$points',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Text(
        'These results show patterns across your entries and are not a formal '
        'assessment. The same behavior may serve more than one function.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: context.colors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}
