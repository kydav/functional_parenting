import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/pro_provider.dart';
import 'package:functional_parenting/core/providers/toolkit_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:functional_parenting/features/tools/presentation/decide_content.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// "What should I do?" — a calm, guided walkthrough. Everyone can reach the
/// "why" behind a behavior for free; the detailed in-the-moment response (do
/// this now / try saying / avoid / after everyone is calm) is part of the
/// toolkit. Any result can be saved or handed off to a free assessment call.
class DecisionToolScreen extends HookConsumerWidget {
  const DecisionToolScreen({super.key, this.initialLeafId});

  /// When set (e.g. re-opening a saved recommendation), the tool starts on that
  /// result instead of the first question.
  final String? initialLeafId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proProvider);

    final path = useState<List<DecideStep>>(_initialPath(initialLeafId));
    final current = path.value.last;
    final atRoot = identical(current, kDecideRoot);

    void go(DecideStep next) => path.value = [...path.value, next];
    void back() => path.value = [...path.value]..removeLast();
    void restart() => path.value = [kDecideRoot];

    return Scaffold(
      appBar: AppBar(
        title: const Text('What should I do?'),
        leading: path.value.length > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: back,
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
            if (current.isLeaf)
              _Result(
                leaf: current.leaf!,
                isPro: isPro,
                onExpertFeedback: () => context.push('/tools/expert-feedback'),
                onUnlock: () => context.push('/paywall'),
                onRestart: restart,
              )
            else ...[
              Text(
                current.question!,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              for (final o in current.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoftCard(
                    onTap: () => go(o.next),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            o.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: context.colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              if (atRoot) ...[const SizedBox(height: 12), const _Disclaimer()],
            ],
          ],
        ),
      ),
    );
  }
}

List<DecideStep> _initialPath(String? leafId) {
  if (leafId != null) {
    final leaf = decideLeafById(leafId);
    if (leaf != null) return [DecideStep(leaf: leaf)];
  }
  return [kDecideRoot];
}

/// A result screen: free "why", Pro-gated action steps, and the follow-up
/// actions (save, expert feedback, start over).
class _Result extends ConsumerWidget {
  final DecideLeaf leaf;
  final bool isPro;
  final VoidCallback onExpertFeedback;
  final VoidCallback onUnlock;
  final VoidCallback onRestart;
  const _Result({
    required this.leaf,
    required this.isPro,
    required this.onExpertFeedback,
    required this.onUnlock,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref
        .watch(savedRecommendationsProvider)
        .maybeWhen(
          data: (list) => list.any((r) => r.leafId == leaf.id),
          orElse: () => false,
        );

    Future<void> toggleSave() async {
      final repo = ref.read(toolkitRepositoryProvider);
      final messenger = ScaffoldMessenger.of(context);
      if (saved) {
        await repo.deleteRecommendation(leaf.id);
        messenger.showSnackBar(const SnackBar(content: Text('Removed.')));
      } else {
        await repo.saveRecommendation(
          leafId: leaf.id,
          category: leaf.category,
          title: leaf.title,
        );
        messenger.showSnackBar(
          const SnackBar(content: Text('Saved to your recommendations.')),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(leaf.category.toUpperCase(), style: _eyebrowStyle),
        const SizedBox(height: 4),
        Text(leaf.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),

        // ── Free: a short orientation and/or the "why" ──────────────────
        if (leaf.note != null)
          _StartCard(leaf.note!)
        else if (leaf.whatsHappening != null)
          _Section(
            label: 'What may be happening',
            icon: Icons.lightbulb_outline_rounded,
            color: kBlueDeep,
            text: leaf.whatsHappening!,
          ),

        // ── Pro: the in-the-moment response ─────────────────────────────
        if (leaf.hasProContent) ...[
          const SizedBox(height: 16),
          if (isPro)
            _ProResponse(leaf: leaf)
          else
            _ProUpsell(onUnlock: onUnlock),
        ],

        const SizedBox(height: 24),

        // ── Follow-up actions ───────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: toggleSave,
            icon: Icon(
              saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 18,
            ),
            label: Text(saved ? 'Saved' : 'Save this recommendation'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onExpertFeedback,
            icon: const Icon(Icons.phone_in_talk_outlined, size: 18),
            label: const Text('Get expert feedback'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: onRestart,
            child: const Text('Start over'),
          ),
        ),
        const SizedBox(height: 96),
      ],
    );
  }
}

/// The Pro "in the moment" block: do-now, scripts, avoid, after-calm.
class _ProResponse extends StatelessWidget {
  final DecideLeaf leaf;
  const _ProResponse({required this.leaf});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leaf.doNow != null)
          SoftCard(
            color: kSage.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow(
                  'Do this now',
                  icon: Icons.bolt_rounded,
                  color: kSageDeep,
                ),
                const SizedBox(height: 10),
                Text(
                  leaf.doNow!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
        if (leaf.trySaying.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Eyebrow('Try saying', icon: Icons.format_quote_rounded),
          const SizedBox(height: 8),
          for (final phrase in leaf.trySaying)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    border: Border.all(color: context.colors.border),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(width: 3, color: kBlueDeep),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              phrase,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    height: 1.5,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
        if (leaf.avoid != null) ...[
          const SizedBox(height: 8),
          _Section(
            label: 'Avoid',
            icon: Icons.do_not_disturb_on_outlined,
            color: kWarmAmber,
            text: leaf.avoid!,
          ),
        ],
        if (leaf.afterCalm != null) ...[
          const SizedBox(height: 16),
          _Section(
            label: 'After everyone is calm',
            icon: Icons.spa_outlined,
            color: kSuccessGreen,
            text: leaf.afterCalm!,
          ),
        ],
      ],
    );
  }
}

/// A labeled paragraph section with a colored eyebrow.
class _Section extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String text;
  const _Section({
    required this.label,
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(label, icon: icon, color: color),
        const SizedBox(height: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      ],
    );
  }
}

/// The free single-paragraph "place to start" (used by "I'm not sure" answers).
class _StartCard extends StatelessWidget {
  final String text;
  const _StartCard(this.text);

  @override
  Widget build(BuildContext context) {
    return SoftCard(
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
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

/// Legal/safety disclaimer shown under the first question.
class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 15,
          color: context.colors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'This tool provides general educational guidance and is not medical '
            'advice. Seek individualized professional support for repeated '
            'aggression, self-injury, elopement, significant developmental '
            'concerns, or other safety risks.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Shown to free users in place of the detailed response.
class _ProUpsell extends StatelessWidget {
  final VoidCallback onUnlock;
  const _ProUpsell({required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: context.colors.brandFill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded, color: kSage, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'See the full in-the-moment response',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The Toolkit unlocks the step-by-step response for each situation — '
            'what to do now, exact words to try, what to avoid, and how to '
            'follow up once everyone is calm.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kSage,
                foregroundColor: kNavy,
              ),
              onPressed: onUnlock,
              child: const Text('Unlock the toolkit'),
            ),
          ),
        ],
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

const _eyebrowStyle = TextStyle(
  color: kBlueDeep,
  fontSize: 11,
  fontWeight: FontWeight.w600,
  letterSpacing: 1.1,
);
