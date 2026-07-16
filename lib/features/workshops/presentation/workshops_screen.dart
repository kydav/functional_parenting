import 'package:flutter/material.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkshopsScreen extends StatelessWidget {
  const WorkshopsScreen({super.key});

  static const _workshops = [
    (
      title: 'Taming the Bedtime Battle',
      date: 'Thu, Jul 24 · 7:00 PM MT',
      format: 'Live on Zoom · Free',
      spots: '12 spots left',
    ),
    (
      title: 'Big Feelings, Small Humans',
      date: 'Tue, Aug 5 · 12:00 PM MT',
      format: 'Live on Zoom · Free',
      spots: 'Filling up',
    ),
  ];

  Future<void> _open(BuildContext context, String label) async {
    // Placeholder — wire to the founder's real booking link (Calendly, etc.).
    final ok = await launchUrl(Uri.parse('https://calendly.com'));
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking link coming soon: $label')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            'Workshops & Coaching',
            subtitle: 'Learn live, or talk one-on-one.',
          ),
          const SizedBox(height: 20),

          // Book a free call — the primary lead-gen CTA.
          SoftCard(
            color: kNavy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow(
                  'Free 15-min call',
                  icon: Icons.phone_in_talk_outlined,
                  color: kBlue,
                ),
                const SizedBox(height: 10),
                Text(
                  'Not sure where to start?',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  "Book a free discovery call and we'll talk through what's happening at home and whether coaching is a fit.",
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
                  onPressed: () => _open(context, 'Discovery call'),
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: const Text('Book a free call'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Upcoming workshops',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          ..._workshops.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            w.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: kSuccessGreen.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            w.spots,
                            style: const TextStyle(
                              color: kSuccessGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _MetaRow(icon: Icons.event_outlined, text: w.date),
                    const SizedBox(height: 6),
                    _MetaRow(icon: Icons.videocam_outlined, text: w.format),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _open(context, w.title),
                        child: const Text('Reserve my spot'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kTextSecondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: kTextSecondary),
        ),
      ],
    );
  }
}
