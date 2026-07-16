import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';

/// A small, self-contained decision flow. In the free app the tree is limited;
/// the full version (deeper branches, saved plans) is a Pro feature.
class DecisionToolScreen extends HookWidget {
  const DecisionToolScreen({super.key});

  static const _root = _Step(
    question: 'Is anyone unsafe right now?',
    options: [
      _Opt('Yes — someone could get hurt', _safety),
      _Opt('No, everyone is safe', _function),
    ],
  );

  static const _safety = _Step(
    guidance:
        'Safety first. Calmly stop the unsafe action and move bodies apart if needed. '
        'Stay close and quiet — narrate less, regulate more. Once everyone is safe and '
        'calmer, come back to the "why" behind the behavior.',
  );

  static const _function = _Step(
    question: 'What does the behavior seem to be reaching for?',
    options: [
      _Opt('Attention / connection', _attention),
      _Opt('To avoid or escape something', _escape),
      _Opt('A tangible — a thing or activity', _tangible),
      _Opt("They're dysregulated / overwhelmed", _regulate),
    ],
  );

  static const _attention = _Step(
    guidance:
        'This behavior is asking to be seen. Give calm, low-drama attention for the behavior '
        "you want, and keep your reaction small for the behavior you don't. Front-load "
        'connection today so the tank is fuller before the next ask.',
  );
  static const _escape = _Step(
    guidance:
        'The demand may feel too big. Break it into a smaller first step, offer a bounded choice, '
        'and acknowledge the hard feeling ("this feels like a lot"). Follow through calmly so words '
        'stay reliable.',
  );
  static const _tangible = _Step(
    guidance:
        'They want the thing. Name it and set the limit clearly ("you want it — and it\'s not for '
        'right now"). Offer when/then ("when shoes are on, then we go"). Avoid negotiating the limit '
        "once it's set.",
  );
  static const _regulate = _Step(
    guidance:
        "A flooded child can't problem-solve. Co-regulate first: lower your voice, get to their level, "
        'and ride the wave with them. Save the teaching for after the storm passes.',
  );

  @override
  Widget build(BuildContext context) {
    final path = useState<List<_Step>>([_root]);
    final current = path.value.last;

    return Scaffold(
      appBar: AppBar(
        title: const Text('What should I do?'),
        leading: path.value.length > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => path.value = [...path.value]..removeLast(),
              )
            : null,
      ),
      body: PageBody(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepDots(count: path.value.length),
            const SizedBox(height: 20),
            if (current.isLeaf) ...[
              SoftCard(
                color: kSage.withValues(alpha: 0.35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow(
                      'A place to start',
                      icon: Icons.tips_and_updates_outlined,
                      color: kSageDeep,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      current.guidance!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => path.value = [_root],
                  child: const Text('Start over'),
                ),
              ),
            ] else ...[
              Text(
                current.question!,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ...current.options.map(
                (o) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoftCard(
                    onTap: () => path.value = [...path.value, o.next],
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            o.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: kTextSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  final int count;
  const _StepDots({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count,
        (i) => Container(
          margin: const EdgeInsets.only(right: 6),
          width: i == count - 1 ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == count - 1 ? kNavy : kBlue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _Step {
  final String? question;
  final String? guidance;
  final List<_Opt> options;
  const _Step({this.question, this.guidance, this.options = const []});
  bool get isLeaf => options.isEmpty;
}

class _Opt {
  final String label;
  final _Step next;
  const _Opt(this.label, this.next);
}
