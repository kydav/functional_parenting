import 'package:flutter/material.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';

/// A single block of readable content inside a Learn bottom sheet.
///
/// Content is authored as an ordered list of blocks (paragraphs, bullet lists,
/// and subheadings) so the source text from the Functional Parenting Toolkit
/// can be transcribed cleanly and rendered consistently in light/dark themes.
sealed class ContentBlock {
  const ContentBlock();
}

/// A body paragraph.
class Para extends ContentBlock {
  final String text;
  const Para(this.text);
}

/// A bold subheading between paragraphs.
class Subhead extends ContentBlock {
  final String text;
  const Subhead(this.text);
}

/// A bulleted list.
class Bullets extends ContentBlock {
  final List<String> items;
  const Bullets(this.items);
}

/// One phase of the Functional Parenting Framework, shown as a card on the
/// Learn screen and expanded into a bottom sheet (Pro only).
class LearnPhase {
  final int number;
  final String title;
  final String summary;
  final List<ContentBlock> content;
  const LearnPhase({
    required this.number,
    required this.title,
    required this.summary,
    required this.content,
  });
}

/// Short teaser shown on the welcome card before the sheet is opened.
const welcomeSnippet =
    'Parenting today can feel overwhelming — and many parents get stuck in a '
    'cycle of repeating themselves, raising their voice, and giving in. '
    'Functional Parenting offers a calmer way forward.';

/// The keeper of the welcome content: the reactive-vs-functional contrast plus
/// the goal. The opening narrative now lives in the first-login intro carousel,
/// so the sheet stays a focused reference.
const welcomeContent = <ContentBlock>[
  Subhead('Reactive parenting vs. Functional Parenting'),
  Para('Reactive parenting often looks like:'),
  Bullets([
    'Repeating directions over and over',
    'Yelling or threatening',
    'Power struggles',
    'Giving in out of exhaustion',
    'Feeling frustrated or defeated',
  ]),
  Para('Functional parenting looks different. Parents learn to:'),
  Bullets([
    'Understand why behavior is happening',
    'Respond with calm, clear structure',
    'Teach skills instead of fighting behavior',
    'Create routines and expectations that support success',
  ]),
  Para(
    'The goal is not perfection. The goal is clarity, consistency, and '
    'confidence in your parenting decisions.',
  ),
];

/// The five phases of the Functional Parenting Framework, in order.
const learnPhases = <LearnPhase>[
  LearnPhase(
    number: 1,
    title: 'Reset the Parent',
    summary: 'Regulate and break reactive cycles',
    content: [
      Para('The first step in the framework may surprise many parents.'),
      Para(
        'Before changing your child’s behavior, we begin by focusing on '
        'your response. This is not because you are the problem — it’s '
        'because parenting is one of the most emotionally demanding roles a '
        'person can have.',
      ),
      Para(
        'When children refuse directions, argue, melt down, or ignore '
        'requests, it is very natural for parents to react quickly. Stress, '
        'fatigue, and repeated behavior challenges can push anyone into '
        'reactive parenting.',
      ),
      Para('Reactive parenting often looks like:'),
      Bullets([
        'Raising your voice',
        'Repeating directions over and over',
        'Arguing with your child',
        'Threatening consequences in frustration',
        'Giving in just to stop the behavior',
      ]),
      Para(
        'These responses are completely understandable, but they often '
        'accidentally fuel the behavior cycle. When emotions escalate on both '
        'sides, children tend to escalate as well.',
      ),
      Para(
        'This is why the first phase of Functional Parenting is learning how '
        'to pause and reset your response. Resetting does not mean you must '
        'always stay perfectly calm. It means developing the ability to pause '
        'long enough to choose your response intentionally instead of '
        'reacting automatically. Even a brief pause can change the direction '
        'of an interaction.',
      ),
      Para(
        'When parents regulate their own response first, they are better able to:',
      ),
      Bullets([
        'Think clearly about what the child needs',
        'Respond consistently',
        'Avoid unnecessary power struggles',
        'Model emotional regulation for their child',
      ]),
      Para(
        'Resetting yourself creates the space needed to apply the rest of the '
        'framework. Before solving the behavior, we first create a moment of '
        'calm and clarity.',
      ),
    ],
  ),
  LearnPhase(
    number: 2,
    title: 'Define the Goal',
    summary: 'Parent with intention',
    content: [
      Para(
        'Once you have learned how to pause and reset your reaction, the next '
        'step is defining the goal.',
      ),
      Para(
        'Many parents understandably focus on stopping behaviors that are '
        'frustrating or disruptive. For example, parents might think:',
      ),
      Bullets([
        '“Make the whining stop.”',
        '“Get my child to stop arguing.”',
        '“Stop the tantrums.”',
        '“Stop the constant fighting between siblings.”',
      ]),
      Para(
        'While these reactions are completely normal, focusing only on '
        'stopping behavior often leads to repeated power struggles. When the '
        'goal is simply “stop the behavior,” parents may find '
        'themselves correcting the same issue over and over without seeing '
        'long-term improvement.',
      ),
      Para(
        'Functional Parenting takes a different approach. Instead of asking '
        '“How do I stop this behavior?” we begin asking “What '
        'skill does my child need to learn instead?”',
      ),
      Para(
        'Every challenging behavior is connected to a skill that is still '
        'developing. For example:',
      ),
      Bullets([
        'Whining may reflect difficulty asking for help appropriately.',
        'Refusing directions may reflect difficulty transitioning between activities.',
        'Meltdowns may reflect difficulty managing frustration or emotional overload.',
        'Arguing may reflect difficulty accepting limits.',
      ]),
      Para(
        'When parents identify the skill behind the behavior, they can begin '
        'guiding their child toward learning that skill instead of getting '
        'stuck in repeated conflicts.',
      ),
      Para(
        'This shift from stopping behavior to building skills is one of the '
        'most powerful changes parents can make. It helps you respond with '
        'greater patience, clarity, and consistency — working toward a '
        'long-term goal for your child’s growth instead of reacting in '
        'the moment.',
      ),
    ],
  ),
  LearnPhase(
    number: 3,
    title: 'Identify the Function',
    summary: 'Understand the “why” behind behavior',
    content: [
      Para(
        'Once you have reset your reaction and clarified the goal you want to '
        'build with your child, the next step is understanding the purpose '
        'behind behavior.',
      ),
      Para(
        'Every behavior serves a function, or a “why.” Children use '
        'behavior as a way to communicate a need, solve a problem, or '
        'influence their environment. Sometimes this communication is '
        'intentional. Other times it happens automatically because the '
        'behavior has worked for the child in the past.',
      ),
      Para(
        'When parents only focus on stopping behavior, they often miss the '
        'reason the behavior is happening. This can lead to repeated cycles '
        'where the same behavior keeps appearing, even after consequences or '
        'corrections.',
      ),
      Para(
        'Functional Parenting helps parents pause and ask a powerful '
        'question: “What is this behavior trying to accomplish?” In '
        'most cases, behavior is driven by one of four common functions:',
      ),
      Bullets([
        'Attention — the child is seeking connection or interaction',
        'Escape — the child is trying to avoid something difficult or unpleasant',
        'Access — the child is trying to obtain something they want',
        'Regulation / Sensory — the child is trying to regulate their body or emotions',
      ]),
      Para(
        'When you understand the function behind behavior, your response '
        'becomes much clearer. Instead of reacting emotionally, you can '
        'choose strategies that address the actual need behind the behavior.',
      ),
    ],
  ),
  LearnPhase(
    number: 4,
    title: 'Build the Structure',
    summary: 'Create systems that support success',
    content: [
      Para(
        'Once you understand the purpose behind your child’s behavior, '
        'the next step is building the structure that supports success.',
      ),
      Para(
        'Many challenging behaviors do not happen because children are '
        'intentionally trying to misbehave. Often, behavior occurs because the '
        'environment around the child is unclear, unpredictable, or '
        'overwhelming.',
      ),
      Para('Children thrive when they know:'),
      Bullets([
        'What is expected',
        'What will happen next',
        'What the limits are',
        'How to succeed in a situation',
      ]),
      Para(
        'When routines and expectations are unclear, children often test '
        'boundaries or become frustrated. This can lead to repeated '
        'arguments, resistance, and power struggles.',
      ),
      Para(
        'Structure helps remove much of this uncertainty. It does not mean '
        'strict control or rigid rules — it means creating clear systems and '
        'predictable patterns that help children succeed. Examples might '
        'include:',
      ),
      Bullets([
        'Consistent morning routines',
        'Clear expectations for homework time',
        'Predictable bedtime routines',
        'Clear transitions between activities',
        'Visual reminders of expectations',
      ]),
      Para('When structure is in place, children often experience:'),
      Bullets([
        'Less confusion',
        'Fewer power struggles',
        'Smoother transitions',
        'Increased independence',
      ]),
      Para(
        'Parents also benefit, because they no longer need to repeat '
        'directions or negotiate expectations constantly. Structure creates a '
        'framework that supports both the parent and the child.',
      ),
    ],
  ),
  LearnPhase(
    number: 5,
    title: 'Respond With Purpose',
    summary: 'Reinforce, teach, and guide behavior',
    content: [
      Para(
        'After resetting your reaction, defining your goal, identifying the '
        'function of behavior, and building supportive structure, the final '
        'step is responding with purpose. This is where parents begin guiding '
        'behavior in a way that supports learning and long-term growth.',
      ),
      Para(
        'Many parents understandably react in the moment with frustration or '
        'urgency. When a child refuses directions, argues, or melts down, it '
        'can feel important to stop the behavior as quickly as possible. '
        'However, reacting emotionally in the moment often leads to repeated '
        'cycles where the same behavior continues to appear.',
      ),
      Para(
        'Responding with purpose means choosing responses that are '
        'intentional, consistent, and connected to the function of the '
        'behavior. Instead of asking “How do I stop this right '
        'now?” Functional Parenting asks “What response will help my '
        'child learn the skill they need?”',
      ),
      Para('Purposeful responses focus on:'),
      Bullets([
        'Reinforcing appropriate behavior',
        'Guiding children toward better choices',
        'Teaching new skills',
        'Maintaining clear expectations',
      ]),
      Para(
        'Over time, these responses help children learn how to navigate '
        'challenges more successfully.',
      ),
    ],
  ),
];

/// Opens a scrollable bottom sheet rendering [content] under [title]. An
/// optional [footer] renders after the content (e.g. a "replay intro" action).
Future<void> showLearnSheet(
  BuildContext context, {
  required String title,
  required List<ContentBlock> content,
  String? eyebrow,
  Widget? footer,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => LearnSheet(
      title: title,
      eyebrow: eyebrow,
      content: content,
      footer: footer,
    ),
  );
}

/// The body of a Learn bottom sheet: a header plus rendered content blocks,
/// height-capped and scrollable for longer phase content.
class LearnSheet extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final List<ContentBlock> content;
  final Widget? footer;
  const LearnSheet({
    required this.title,
    required this.content,
    this.eyebrow,
    this.footer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (eyebrow != null) ...[
                  Eyebrow(eyebrow!),
                  const SizedBox(height: 8),
                ],
                Text(title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 16),
                for (final block in content) ...[
                  _ContentBlockView(block),
                  const SizedBox(height: 14),
                ],
                if (footer != null) ...[const SizedBox(height: 2), footer!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentBlockView extends StatelessWidget {
  final ContentBlock block;
  const _ContentBlockView(this.block);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (block) {
      case Para(:final text):
        return Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
        );
      case Subhead(:final text):
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(text, style: theme.textTheme.titleMedium),
        );
      case Bullets(:final items):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7, right: 10),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: kBlueDeep,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
    }
  }
}
