import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/models/workshop.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';
import 'package:functional_parenting/core/providers/workshop_provider.dart';
import 'package:functional_parenting/core/services/notification_service.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkshopsScreen extends ConsumerWidget {
  const WorkshopsScreen({super.key});

  Future<void> _openCall(BuildContext context) async {
    // Placeholder — wire to the founder's real booking link (Calendly, etc.).
    final ok = await launchUrl(Uri.parse('https://calendly.com'));
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking link coming soon.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workshopsAsync = ref.watch(workshopsProvider);

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
            color: context.colors.brandFill,
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
                  onPressed: () => _openCall(context),
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
          workshopsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Could not load workshops: $e'),
            data: (all) {
              final upcoming = all.where((w) => w.isUpcoming).toList();
              if (upcoming.isEmpty) {
                return SoftCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No workshops scheduled right now — check back soon.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: context.colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  for (final w in upcoming) ...[
                    _WorkshopCard(workshop: w),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WorkshopCard extends HookConsumerWidget {
  final Workshop workshop;
  const _WorkshopCard({required this.workshop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reserved =
        ref.watch(myReservationProvider(workshop.id)).value ?? false;
    final busy = useState(false);

    // Keep the 10-minutes-before reminder in sync with reservation state. This
    // also reschedules on launch / a new device where the local alarm was lost.
    useEffect(() {
      final notifs = NotificationService.instance;
      if (reserved && workshop.isUpcoming) {
        notifs.scheduleWorkshopReminder(
          workshopId: workshop.id,
          title: workshop.title,
          startsAt: workshop.startsAt,
        );
      } else {
        notifs.cancelWorkshopReminder(workshop.id);
      }
      return null;
    }, [reserved, workshop.startsAt]);

    Future<void> toggle() async {
      final auth = ref.read(authNotifierProvider);
      final uid = auth.currentUser?.uid;
      if (uid == null) return;
      busy.value = true;
      final repo = ref.read(workshopRepositoryProvider);
      try {
        if (reserved) {
          await repo.cancelReservation(workshop.id, uid);
        } else {
          await repo.reserve(workshop.id, uid, auth.userName);
        }
      } finally {
        busy.value = false;
      }
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(workshop.title, style: Theme.of(context).textTheme.titleLarge),
          if (workshop.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              workshop.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
          const SizedBox(height: 10),
          _MetaRow(
            icon: Icons.event_outlined,
            text: DateFormat('EEE, MMM d').format(workshop.startsAt),
          ),
          const SizedBox(height: 6),
          _MetaRow(
            icon: Icons.schedule,
            text: DateFormat('h:mm a').format(workshop.startsAt),
          ),
          const SizedBox(height: 14),
          if (reserved) ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: kSuccessGreen, size: 18),
                const SizedBox(width: 6),
                Text(
                  "Reserved — we'll remind you 10 min before",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: kSuccessGreen),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (workshop.joinLink.isNotEmpty)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(workshop.joinLink),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.videocam_rounded, size: 18),
                      label: const Text('Join'),
                    ),
                  ),
                if (workshop.joinLink.isNotEmpty) const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy.value ? null : toggle,
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: busy.value ? null : toggle,
                child: busy.value
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Reserve my spot'),
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
        Icon(icon, size: 16, color: context.colors.textSecondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
        ),
      ],
    );
  }
}
