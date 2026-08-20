import 'package:flutter/material.dart';
import 'package:functional_parenting/core/services/analytics_service.dart';
import 'package:functional_parenting/core/services/feedback_service.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';

/// Opens the feedback composer as a bottom sheet. [rating] is passed through
/// when it originated from the rating prompt; [source] tags where it came from
/// (`'profile'` | `'rating_prompt'`).
Future<void> showFeedbackSheet(
  BuildContext context, {
  int? rating,
  String source = 'profile',
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FeedbackSheet(rating: rating, source: source),
  );
}

class _FeedbackSheet extends StatefulWidget {
  final int? rating;
  final String source;
  const _FeedbackSheet({required this.rating, required this.source});

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await FeedbackService.submit(
        message: text,
        rating: widget.rating,
        source: widget.source,
      );
      AnalyticsService.instance.track('feedback_submitted', {
        'source': widget.source,
        if (widget.rating != null) 'rating': widget.rating!,
      });
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Thanks — we read every note.')),
      );
    } catch (_) {
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't send just now. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 18 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.source == 'rating_prompt'
                ? 'Tell us how we can do better'
                : 'Send feedback',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Ideas, bugs, or anything on your mind — it goes straight to the '
            'team.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'What would you like us to know?',
              filled: true,
              fillColor: context.colors.surfaceAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send'),
            ),
          ),
        ],
      ),
    );
  }
}
