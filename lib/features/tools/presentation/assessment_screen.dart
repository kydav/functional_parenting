import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';

/// The one free behavior-pattern assessment. A short Likert quiz that maps
/// answers to the most likely behavior *function*, then points at next steps.
class AssessmentScreen extends HookWidget {
  const AssessmentScreen({super.key});

  static const _questions = <(String, String)>[
    (
      'The behavior happens most when my child wants my attention or company.',
      'Attention',
    ),
    (
      'It shows up right before or during a task they find hard or boring.',
      'Escape',
    ),
    (
      "It happens when they can't have a specific item or activity.",
      'Tangible',
    ),
    ("It appears when they're tired, hungry, or overstimulated.", 'Regulation'),
    ('It fades quickly once I give attention or connection.', 'Attention'),
    ('It stops as soon as the demand is removed.', 'Escape'),
  ];

  static const _labels = ['Rarely', 'Sometimes', 'Often', 'Almost always'];

  @override
  Widget build(BuildContext context) {
    // 0..3 per question, -1 = unanswered.
    final answers = useState<List<int>>(List.filled(_questions.length, -1));
    final submitted = useState(false);

    final answeredAll = !answers.value.contains(-1);

    return Scaffold(
      appBar: AppBar(title: const Text('Behavior-pattern check')),
      body: PageBody(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: submitted.value
            ? _Result(
                scores: _score(answers.value),
                onRestart: () {
                  answers.value = List.filled(_questions.length, -1);
                  submitted.value = false;
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Think of one behavior you want to understand. How true is each statement?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: kTextSecondary,
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
                                  selectedColor: kNavy,
                                  backgroundColor: kBgPage,
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : kTextPrimary,
                                    fontSize: 12,
                                  ),
                                  side: const BorderSide(color: kBorderColor),
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
    final scores = <String, int>{};
    for (var i = 0; i < _questions.length; i++) {
      final fn = _questions[i].$2;
      scores[fn] = (scores[fn] ?? 0) + (answers[i] + 1);
    }
    return scores;
  }
}

class _Result extends StatelessWidget {
  final Map<String, int> scores;
  final VoidCallback onRestart;
  const _Result({required this.scores, required this.onRestart});

  static const _guidance = {
    'Attention':
        "The pattern points toward attention / connection. Try front-loading positive attention and keeping your reaction small for the behavior you don't want.",
    'Escape':
        'The pattern points toward escape / avoidance. Break demands into smaller steps, offer bounded choices, and acknowledge the hard feeling.',
    'Tangible':
        'The pattern points toward access to a tangible. Use clear limits with "when/then", and avoid re-negotiating once the limit is set.',
    'Regulation':
        'The pattern points toward regulation. Watch for hunger, tiredness, and overstimulation, and co-regulate before you teach.',
  };

  @override
  Widget build(BuildContext context) {
    final top = scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final maxScore = scores.values.fold(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Your likely pattern', icon: Icons.insights_rounded),
        const SizedBox(height: 10),
        Text(top, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        SoftCard(
          color: kBlue.withValues(alpha: 0.2),
          child: Text(
            _guidance[top]!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'How your answers broke down',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...scores.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    e.key,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: maxScore == 0 ? 0 : e.value / maxScore,
                      minHeight: 10,
                      backgroundColor: kBorderColor,
                      color: e.key == top ? kNavy : kBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SoftCard(
          color: kSage.withValues(alpha: 0.35),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'Track this behavior over time with the ABC tracker to confirm the pattern.',
                  style: TextStyle(height: 1.5, fontSize: 14),
                ),
              ),
              SizedBox(width: 12),
              ProBadge(),
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
