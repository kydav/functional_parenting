import 'package:flutter/material.dart';
import 'package:functional_parenting/core/constants.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/services/analytics_service.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Reached from a "What should I do?" recommendation via "Get expert feedback".
/// Frames the free Behavior Pattern Assessment call as the next step.
class ExpertFeedbackScreen extends StatelessWidget {
  const ExpertFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(height: 1.6);

    return Scaffold(
      appBar: AppBar(title: const Text('Get expert feedback')),
      body: PageBody(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Want help turning this guidance into a plan for your family?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 14),
            Text(
              'This tool gives you a helpful starting point based on the '
              'pattern you selected, but behavior is rarely one-size-fits-all. '
              'The same behavior can happen for different reasons, and small '
              'details — such as what happens before it, how you respond, and '
              'what your child does next — can change the best approach.',
              style: bodyStyle,
            ),
            const SizedBox(height: 14),
            Text(
              'During a free Behavior Pattern Assessment Call, we will look '
              'more closely at what is happening in your home, identify the '
              'patterns that may be keeping the behavior going, and discuss '
              'practical next steps tailored to your family.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),
            SoftCard(
              color: context.colors.brandFill,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Eyebrow(
                    'Free 15-min call',
                    icon: Icons.phone_in_talk_outlined,
                    color: kBlue,
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: kBlue,
                      foregroundColor: kNavy,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: () {
                      AnalyticsService.instance.track('book_call_tapped', {
                        'source': 'expert_feedback',
                      });
                      launchUrl(Uri.parse(kBookACallUrl));
                    },
                    icon: const Icon(Icons.calendar_month_rounded, size: 18),
                    label: const Text('Book My Free Assessment Call'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Get expert feedback on one of your family’s most '
                    'challenging behavior patterns.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
