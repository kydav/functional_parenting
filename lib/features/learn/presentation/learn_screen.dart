import 'package:flutter/material.dart';

import '../../../core/presentation/widgets.dart';
import '../../../core/theme/app_theme.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  static const _pillars = [
    (
      icon: Icons.hearing_rounded,
      title: 'Behavior is communication',
      body:
          'Every behavior serves a function — to get something, avoid something, or meet a need. We decode the message before we respond to the behavior.',
    ),
    (
      icon: Icons.favorite_border_rounded,
      title: 'Connection before correction',
      body:
          'A regulated, connected child can learn. We build the relationship first, then guide the behavior.',
    ),
    (
      icon: Icons.repeat_rounded,
      title: 'Consistency over intensity',
      body:
          'Small, predictable responses repeated over time teach far more than big reactions. Calm and consistent wins.',
    ),
    (
      icon: Icons.trending_up_rounded,
      title: 'Skill-building, not punishment',
      body:
          'Behavior we want to see is a skill we can teach, reinforce, and practice — not just something to suppress.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            'The Framework',
            subtitle:
                'A functional approach to understanding and shaping behavior.',
          ),
          const SizedBox(height: 20),
          SoftCard(
            color: kNavy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow(
                  'Start here',
                  icon: Icons.play_circle_outline,
                  color: kBlue,
                ),
                const SizedBox(height: 10),
                Text(
                  'What is Functional Parenting?',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'A short intro to the mindset and method — why we look at the function behind behavior, and how that changes what we do next.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: kBlue,
                    foregroundColor: kNavy,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Watch intro (3 min)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'The four pillars',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          ..._pillars.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SoftCard(
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
                      child: Icon(p.icon, color: kNavy, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.body,
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
            ),
          ),
          const SizedBox(height: 8),
          SoftCard(
            color: kSage.withValues(alpha: 0.35),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Go deeper with the self-paced course — 8 guided modules with video, audio, and planning tools.',
                    style: TextStyle(height: 1.5, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                const ProBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
