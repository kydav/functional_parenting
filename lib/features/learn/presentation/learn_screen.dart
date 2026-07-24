import 'package:flutter/material.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/pro_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:functional_parenting/features/learn/presentation/learn_content.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proProvider);
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
            color: context.colors.brandFill,
            onTap: () => showLearnSheet(
              context,
              eyebrow: 'Welcome',
              title: 'What is Functional Parenting?',
              content: welcomeContent,
              footer: Builder(
                builder: (sheetContext) => TextButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    sheetContext.push('/welcome');
                  },
                  icon: const Icon(Icons.replay_rounded, size: 18),
                  label: const Text('Replay the intro'),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow(
                  'Start here',
                  icon: Icons.auto_stories_outlined,
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
                  welcomeSnippet,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Text(
                      'Read the welcome',
                      style: TextStyle(
                        color: kBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: kBlue, size: 18),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'The 5 phases',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Work through the Functional Parenting Framework, one phase at a time.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...learnPhases.map(
            (phase) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PhaseCard(phase: phase, isPro: isPro),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final LearnPhase phase;
  final bool isPro;
  const _PhaseCard({required this.phase, required this.isPro});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: () {
        if (isPro) {
          showLearnSheet(
            context,
            eyebrow: 'Phase ${phase.number}',
            title: phase.title,
            content: phase.content,
          );
        } else {
          context.push('/paywall');
        }
      },
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kBlue.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${phase.number}',
              style: const TextStyle(
                color: kNavy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phase.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  phase.summary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isPro)
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.textSecondary,
            )
          else ...[
            const ProBadge(),
            const SizedBox(width: 6),
            Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: context.colors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }
}
