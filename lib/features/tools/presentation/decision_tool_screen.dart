import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/pro_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A small, self-contained decision flow. The free tree gives one solid place
/// to start for each function; Pro unlocks a deeper follow-up branch with more
/// specific next steps (any leaf whose `more` is set).
class DecisionToolScreen extends HookConsumerWidget {
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

  // ── Attention ─────────────────────────────────────────────────────────────
  static const _attention = _Step(
    guidance:
        'This behavior is asking to be seen. Give calm, low-drama attention for the behavior '
        "you want, and keep your reaction small for the behavior you don't. Front-load "
        'connection today so the tank is fuller before the next ask.',
    more: _attentionMore,
  );
  static const _attentionMore = _Step(
    question: 'What tends to happen in the moment?',
    options: [
      _Opt('I stop and give in to keep the peace', _attentionGiveIn),
      _Opt('I repeat myself / it escalates', _attentionEscalate),
    ],
  );
  static const _attentionGiveIn = _Step(
    guidance:
        'If big behavior reliably earns your attention, it becomes the tool that works. '
        'Flip it: give brief, warm attention the moment they do the calm version ("I love how '
        'you asked me"), and keep your response to the loud version small and boring. Then '
        'schedule connection you initiate — 10 device-free minutes at a predictable time — so '
        "attention isn't something they have to fight for.",
  );
  static const _attentionEscalate = _Step(
    guidance:
        'Repeating and reacting is still attention, and it fuels the loop. Say it once, calmly, '
        'then let your face and body go neutral. Catch the first flicker of the behavior you '
        'want and pour warmth in there instead. The contrast — big for calm, small for chaos — '
        'is what teaches the shift.',
  );

  // ── Escape / avoidance ──────────────────────────────────────────────────
  static const _escape = _Step(
    guidance:
        'The demand may feel too big. Break it into a smaller first step, offer a bounded choice, '
        'and acknowledge the hard feeling ("this feels like a lot"). Follow through calmly so words '
        'stay reliable.',
    more: _escapeMore,
  );
  static const _escapeMore = _Step(
    question: 'Does this task truly have to happen right now?',
    options: [
      _Opt('Yes — it has to happen', _escapeMust),
      _Opt('It could wait or be adjusted', _escapeFlex),
    ],
  );
  static const _escapeMust = _Step(
    guidance:
        'Make the mountain a step. Name the very first tiny action ("just shoes on"), then a '
        'when-then for what follows ("when shoes are on, then we head out"). Offer control inside '
        'the task, not over whether it happens ("red socks or blue?"). Stay warm and boring, and '
        'let the follow-through — not more words — carry it.',
  );
  static const _escapeFlex = _Step(
    guidance:
        "If there's room, lower the demand instead of the boom. Shorten it, do the first bit "
        'together, or delay with a clear plan ("we\'ll do it after snack"). Handing back a little '
        'control now prevents the power struggle — and keeps the task from becoming a battle line.',
  );

  // ── Tangible ─────────────────────────────────────────────────────────────
  static const _tangible = _Step(
    guidance:
        'They want the thing. Name it and set the limit clearly ("you want it — and it\'s not for '
        'right now"). Offer when/then ("when shoes are on, then we go"). Avoid negotiating the limit '
        "once it's set.",
    more: _tangibleMore,
  );
  static const _tangibleMore = _Step(
    question: 'Is something ending, or is this a brand-new want?',
    options: [
      _Opt("They had it and it's ending", _tangibleEnding),
      _Opt("It's a new demand", _tangibleNew),
    ],
  );
  static const _tangibleEnding = _Step(
    guidance:
        'Transitions off a good thing are hard. Warn before you switch ("two more minutes, then '
        'we\'re all done"), make the ending concrete with a timer or a last turn, and name what\'s '
        "next so there's somewhere to go. Expect the protest and stay steady — the limit holds "
        'even while you hold the feeling.',
  );
  static const _tangibleNew = _Step(
    guidance:
        'A new demand is a chance to teach asking and waiting. Show the words ("Can I have a turn, '
        'please?"), then a short, doable wait ("after we finish here"). Reward the calm ask and the '
        'wait — not the escalation — so the polite path becomes the one that works.',
  );

  // ── Regulation ───────────────────────────────────────────────────────────
  static const _regulate = _Step(
    guidance:
        "A flooded child can't problem-solve. Co-regulate first: lower your voice, get to their level, "
        'and ride the wave with them. Save the teaching for after the storm passes.',
    more: _regulateMore,
  );
  static const _regulateMore = _Step(
    question: 'Right now, are they still ramping up or starting to settle?',
    options: [
      _Opt('Still escalating', _regulateEscalating),
      _Opt('Starting to come down', _regulateSettling),
    ],
  );
  static const _regulateEscalating = _Step(
    guidance:
        'At peak flood, less is more. Cut the words, dim the input (noise, lights, audience), and '
        'keep everyone safe. Offer your calm presence, not a lesson — a steady hand, a low voice, '
        "space if they need it. You are the anchor; you don't have to fix it, just outlast the wave.",
  );
  static const _regulateSettling = _Step(
    guidance:
        'As they come down, reconnect before you correct. Name the feeling ("that was really hard"), '
        'offer a bridge back (water, a hug, a quiet job to do together), and keep repair light. Save '
        "any problem-solving for later, when they're fully regulated and can actually take it in.",
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proProvider);
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
              if (current.more != null) ...[
                const SizedBox(height: 16),
                if (isPro)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          path.value = [...path.value, current.more!],
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('More specific next steps'),
                    ),
                  )
                else
                  _ProUpsell(onUnlock: () => context.push('/paywall')),
              ],
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
                        Icon(
                          Icons.chevron_right_rounded,
                          color: context.colors.textSecondary,
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

/// Shown at a free stopping point that has deeper Pro guidance available.
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
                  "There's a more specific next step for this",
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The Starter Toolkit unlocks a deeper follow-up for each situation — '
            "tailored to what's actually happening in the moment.",
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

class _Step {
  final String? question;
  final String? guidance;
  final List<_Opt> options;

  /// A deeper follow-up reachable only by Pro users. When set on a leaf, free
  /// users see an upsell in its place.
  final _Step? more;
  const _Step({
    this.question,
    this.guidance,
    this.options = const [],
    this.more,
  });
  bool get isLeaf => options.isEmpty;
}

class _Opt {
  final String label;
  final _Step next;
  const _Opt(this.label, this.next);
}
