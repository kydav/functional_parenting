import 'package:flutter/material.dart';
import 'package:functional_parenting/core/presentation/feedback_sheet.dart';
import 'package:functional_parenting/core/services/analytics_service.dart';
import 'package:functional_parenting/core/services/rating_prompt_service.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:in_app_review/in_app_review.dart';

/// Shows the rating prompt if eligible. 4–5 stars → native store review; 1–3
/// stars → the feedback composer. Fires analytics for shown / dismissed /
/// submitted (with the star value).
Future<void> maybeShowRatingPrompt(BuildContext context) async {
  final svc = RatingPromptService.instance;
  if (!svc.shouldPrompt) return;
  svc.markShown();
  AnalyticsService.instance.track('rating_prompt_shown');

  final rating = await showDialog<int>(
    context: context,
    builder: (_) => const _RatingDialog(),
  );

  if (rating == null) {
    AnalyticsService.instance.track('rating_prompt_dismissed');
    await svc.markDismissed();
    return;
  }

  AnalyticsService.instance.track('rating_submitted', {'rating': rating});
  await svc.markCompleted();

  if (rating >= 4) {
    try {
      final review = InAppReview.instance;
      if (await review.isAvailable()) await review.requestReview();
    } catch (_) {
      // Store review is best-effort.
    }
  } else if (context.mounted) {
    await showFeedbackSheet(context, rating: rating, source: 'rating_prompt');
  }
}

class _RatingDialog extends StatefulWidget {
  const _RatingDialog();

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface,
      title: const Text('Enjoying Functional Parenting?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How would you rate your experience so far?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _rating = i),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    i <= _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: i <= _rating ? kSage : context.colors.textSecondary,
                    size: 36,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: _rating == 0
              ? null
              : () => Navigator.pop(context, _rating),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
