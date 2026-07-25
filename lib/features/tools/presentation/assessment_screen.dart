import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/pro_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// The four behavior functions, in canonical display order. Used as the score
// keys so tie-breaking and the breakdown bars are stable.
const _attention = 'Attention or connection';
const _escape = 'Avoidance or escape';
const _tangible = 'Tangible or activity';
const _regulation = 'Dysregulation or overwhelm';
const _functions = [_attention, _escape, _tangible, _regulation];

/// The one free behavior-pattern check. A balanced Likert quiz — three
/// statements per function — that maps answers to the most likely behavior
/// *function(s)*, then points at next steps.
class AssessmentScreen extends HookConsumerWidget {
  const AssessmentScreen({super.key});

  // (statement, function). Three statements per function, interleaved.
  static const _questions = <(String, String)>[
    (
      'The behavior is more likely when my child is asked to begin a '
          'difficult, disliked, or non-preferred task.',
      _escape,
    ),
    (
      'The behavior often results in an adult talking to, comforting, '
          'correcting, or interacting with my child.',
      _attention,
    ),
    (
      'The behavior is more likely when my child seems tired, overstimulated, '
          'frustrated, or emotionally overwhelmed.',
      _regulation,
    ),
    (
      'The behavior often happens when my child is asked to complete a task, '
          'follow a direction, or do something they do not want to do.',
      _escape,
    ),
    (
      'The behavior is more likely when my child wants an item, snack, screen, '
          'toy, or activity they cannot have right away.',
      _tangible,
    ),
    (
      'The behavior sometimes seems to help my child release tension, cope '
          'with discomfort, or regulate their body.',
      _regulation,
    ),
    (
      'The behavior is more likely when my attention is focused on another '
          'person, task, or device.',
      _attention,
    ),
    (
      'The behavior often delays, shortens, or removes a demand, task, '
          'transition, or expectation.',
      _escape,
    ),
    (
      'The behavior is more likely when my child is told “no,” asked to wait, '
          'or cannot access something they want.',
      _tangible,
    ),
    (
      'The behavior often leads to my child receiving reassurance, closeness, '
          'conversation, or another form of attention.',
      _attention,
    ),
    (
      'The behavior is more likely during noisy, crowded, unpredictable, or '
          'highly stimulating situations.',
      _regulation,
    ),
    (
      'The behavior often leads to my child getting the item or activity they '
          'were asking for.',
      _tangible,
    ),
  ];

  static const _labels = ['Rarely', 'Sometimes', 'Often', 'Almost always'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proProvider);

    // 0..3 per question, -1 = unanswered.
    final answers = useState<List<int>>(List.filled(_questions.length, -1));
    final submitted = useState(false);

    final answeredAll = !answers.value.contains(-1);

    return Scaffold(
      appBar: AppBar(title: const Text('Behavior-pattern check')),
      body: PageBody(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
        child: submitted.value
            ? _Result(
                scores: _score(answers.value),
                onOpenTracker: () =>
                    context.push(isPro ? '/tools/tracker' : '/paywall'),
                isPro: isPro,
                onRestart: () {
                  answers.value = List.filled(_questions.length, -1);
                  submitted.value = false;
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Think of one behavior you want to understand. How true is '
                    'each statement?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_questions.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SoftCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _questions[i].$1,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(4, (v) {
                                final selected = answers.value[i] == v;
                                return ChoiceChip(
                                  label: Text(_labels[v]),
                                  selected: selected,
                                  showCheckmark: false,
                                  backgroundColor: context.colors.pageBg,
                                  labelStyle: TextStyle(
                                    color: context.colors.textPrimary,
                                    fontSize: 12,
                                  ),
                                  side: BorderSide(
                                    color: context.colors.border,
                                  ),
                                  onSelected: (_) {
                                    final next = [...answers.value];
                                    next[i] = v;
                                    answers.value = next;
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: answeredAll
                          ? () => submitted.value = true
                          : null,
                      child: const Text('See my result'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Map<String, int> _score(List<int> answers) {
    final scores = {for (final f in _functions) f: 0};
    for (var i = 0; i < _questions.length; i++) {
      final fn = _questions[i].$2;
      scores[fn] = scores[fn]! + (answers[i] + 1); // Rarely=1 … Almost always=4
    }
    return scores;
  }
}

class _Result extends StatelessWidget {
  final Map<String, int> scores;
  final bool isPro;
  final VoidCallback onOpenTracker;
  final VoidCallback onRestart;
  const _Result({
    required this.scores,
    required this.isPro,
    required this.onOpenTracker,
    required this.onRestart,
  });

  static const _guidance = {
    _attention:
        'The pattern points toward attention / connection. Try front-loading '
        "positive attention and keeping your reaction small for the behavior "
        "you don't want.",
    _escape:
        'The pattern points toward escape / avoidance. Break demands into '
        'smaller steps, offer bounded choices, and acknowledge the hard '
        'feeling.',
    _tangible:
        'The pattern points toward access to a tangible. Use clear limits '
        'with "when/then", and avoid re-negotiating once the limit is set.',
    _regulation:
        'The pattern points toward regulation. Watch for hunger, tiredness, '
        'and overstimulation, and co-regulate before you teach.',
  };

  @override
  Widget build(BuildContext context) {
    final maxScore = scores.values.fold(0, (a, b) => a > b ? a : b);
    // Every function tied for the top score (canonical order preserved).
    final top = _functions.where((f) => scores[f] == maxScore).toList();
    final multiple = top.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(
          multiple ? 'Your likely patterns' : 'Your likely pattern',
          icon: Icons.insights_rounded,
        ),
        const SizedBox(height: 10),
        if (!multiple)
          Text(top.first, style: Theme.of(context).textTheme.headlineSmall),
        for (final f in top) ...[
          if (multiple) ...[
            const SizedBox(height: 4),
            Text(f, style: Theme.of(context).textTheme.titleLarge),
          ],
          const SizedBox(height: 12),
          SoftCard(
            color: kBlue.withValues(alpha: 0.2),
            child: Text(
              _guidance[f]!,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 12),
        Text(
          'How your answers broke down',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        for (final f in _functions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(f, style: Theme.of(context).textTheme.bodySmall),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: maxScore == 0 ? 0 : scores[f]! / maxScore,
                      minHeight: 10,
                      backgroundColor: context.colors.border,
                      color: top.contains(f) ? kNavy : kBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'This check identifies possible behavior patterns based on your '
          'responses. A behavior may serve more than one purpose, and the '
          'results are not a formal assessment.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.colors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),

        // Track over time — routes to the ABC tracker (Pro) or the paywall.
        SoftCard(
          color: kSage.withValues(alpha: 0.35),
          onTap: onOpenTracker,
          child: Row(
            children: [
              const Icon(Icons.checklist_rounded, color: kSageDeep),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'To better understand the why behind this behavior, track it '
                  'over time with the ABC tracker.',
                  style: TextStyle(height: 1.5, fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              if (isPro)
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.colors.textSecondary,
                )
              else
                const ProBadge(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onRestart,
            child: const Text('Retake'),
          ),
        ),
      ],
    );
  }
}
