import 'package:flutter/material.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';

/// Static, plain-language reference for the four functions of behavior.
/// Part of the Starter Toolkit — helps a parent read the ABC log they collect
/// in the tracker and decide what to put in an action plan.
class BehaviorFunctionGuideScreen extends StatelessWidget {
  const BehaviorFunctionGuideScreen({super.key});

  static const _functions = [
    (
      icon: Icons.pan_tool_alt_outlined,
      color: kBlueDeep,
      title: 'Attention',
      gist: 'The behavior gets someone to notice and respond.',
      looks:
          'Interrupting, whining, silliness that ramps up when you look away, '
          'melting down the moment you pick up your phone.',
      helps:
          'Give warm attention before it’s demanded — “catch them being good.” '
          'Teach a clear way to ask for you (a tap, a word, a signal), and '
          'keep your response calm and brief when the behavior shows up.',
    ),
    (
      icon: Icons.logout_rounded,
      color: kSageDeep,
      title: 'Escape or avoidance',
      gist: 'The behavior helps them get out of something hard or unwanted.',
      looks:
          'Big reactions at bath time, homework, transitions, or getting '
          'dressed. It often “works” because the demand goes away.',
      helps:
          'Break the task into smaller steps, offer a real choice within it, '
          'and use a first–then (“first shoes, then park”). Follow through so '
          'the behavior doesn’t become the exit, and praise the effort.',
    ),
    (
      icon: Icons.redeem_outlined,
      color: kSuccessGreen,
      title: 'Access to something',
      gist: 'The behavior gets a toy, a snack, a screen, or an activity.',
      looks:
          'Escalating at the store checkout, at screen-time’s end, or when a '
          'sibling has the thing they want.',
      helps:
          'Set the expectation up front and name the plan (“two more minutes, '
          'then we turn it off”). Teach asking and waiting, and reward the '
          'calm version — not the meltdown — with the thing they wanted.',
    ),
    (
      icon: Icons.spa_outlined,
      color: kWarmAmber,
      title: 'Sensory or regulation',
      gist:
          'The behavior feels good, soothes, or releases energy — it’s not '
          'really about you.',
      looks:
          'Happens alone as much as with others: spinning, humming, chewing, '
          'crashing into things, movement when overwhelmed.',
      helps:
          'Build in movement and sensory input before they’re dysregulated. '
          'Offer a safe replacement that meets the same need, and reduce '
          'triggers like noise, hunger, or tiredness where you can.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Behavior-function guide')),
      body: PageBody(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why is this happening?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Almost every behavior is trying to get one of four things. When '
              'you can name the function, the response gets a lot clearer — and '
              'so does the plan. Use your tracker logs to spot the pattern.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
            for (final f in _functions) ...[
              _FunctionCard(
                icon: f.icon,
                color: f.color,
                title: f.title,
                gist: f.gist,
                looks: f.looks,
                helps: f.helps,
              ),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 4),
            SoftCard(
              color: context.colors.surfaceAlt,
              child: Text(
                'A behavior can serve more than one function, and it can change '
                'over time. Treat this as a starting hypothesis — then test it '
                'with what you see in the tracker.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.5,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FunctionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String gist;
  final String looks;
  final String helps;
  const _FunctionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.gist,
    required this.looks,
    required this.helps,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            gist,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          _Labeled(label: 'What it can look like', text: looks),
          const SizedBox(height: 10),
          _Labeled(label: 'What tends to help', text: helps),
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  final String label;
  final String text;
  const _Labeled({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }
}
