import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/models/workshop.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/workshop_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class WorkshopsAdminScreen extends ConsumerWidget {
  const WorkshopsAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allWorkshopsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage workshops')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Workshop'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (workshops) {
          if (workshops.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No workshops yet. Tap "Workshop" to create one.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              for (final w in workshops) ...[
                _WorkshopAdminCard(workshop: w),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _WorkshopAdminCard extends ConsumerWidget {
  final Workshop workshop;
  const _WorkshopAdminCard({required this.workshop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations =
        ref.watch(reservationsProvider(workshop.id)).value ?? const [];
    final past = !workshop.isUpcoming;

    return Opacity(
      opacity: workshop.active ? 1 : 0.6,
      child: SoftCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            title: Text(
              workshop.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              '${DateFormat('EEE, MMM d · h:mm a').format(workshop.startsAt)}'
              '${past ? ' · past' : ''}${workshop.active ? '' : ' · hidden'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kBlue.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${reservations.length} 👤',
                style: const TextStyle(
                  color: kNavy,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            children: [
              if (reservations.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No reservations yet.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                ...reservations.map(
                  (r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: kBlueDeep,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(r.name.isEmpty ? 'Anonymous' : r.name),
                        ),
                        if (r.reservedAt != null)
                          Text(
                            DateFormat('MMM d').format(r.reservedAt!),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                      ],
                    ),
                  ),
                ),
              const Divider(height: 20),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        _openSheet(context, ref, existing: workshop),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete workshop?'),
                          content: const Text(
                            'This removes the workshop and its reservations.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await ref
                            .read(workshopRepositoryProvider)
                            .deleteWorkshop(workshop.id);
                      }
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _openSheet(BuildContext context, WidgetRef ref, {Workshop? existing}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _WorkshopSheet(existing: existing),
    ),
  );
}

class _WorkshopSheet extends HookConsumerWidget {
  final Workshop? existing;
  const _WorkshopSheet({this.existing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = useTextEditingController(text: existing?.title ?? '');
    final description = useTextEditingController(
      text: existing?.description ?? '',
    );
    final joinLink = useTextEditingController(text: existing?.joinLink ?? '');
    final when = useState<DateTime>(
      existing?.startsAt ?? DateTime.now().add(const Duration(days: 7)),
    );
    final active = useState<bool>(existing?.active ?? true);

    Future<void> pickWhen() async {
      final date = await showDatePicker(
        context: context,
        initialDate: when.value,
        firstDate: DateTime.now().subtract(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (date == null || !context.mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(when.value),
      );
      if (time == null) return;
      when.value = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }

    Future<void> save() async {
      if (title.text.trim().isEmpty) return;
      final w = Workshop(
        id: existing?.id ?? '',
        title: title.text.trim(),
        description: description.text.trim(),
        startsAt: when.value,
        joinLink: joinLink.text.trim(),
        active: active.value,
      );
      await ref.read(workshopRepositoryProvider).saveWorkshop(w);
      if (context.mounted) Navigator.pop(context);
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              existing == null ? 'New workshop' : 'Edit workshop',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const _Label('Title'),
            TextField(
              controller: title,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            const _Label('Description'),
            TextField(controller: description, maxLines: 3),
            const SizedBox(height: 14),
            const _Label('Date & time'),
            OutlinedButton.icon(
              onPressed: pickWhen,
              icon: const Icon(Icons.event_outlined, size: 18),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('EEE, MMM d · h:mm a').format(when.value),
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 14),
            const _Label('Join link'),
            TextField(
              controller: joinLink,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: 'https://zoom.us/j/…',
              ),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Visible to users'),
              value: active.value,
              onChanged: (v) => active.value = v,
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: save, child: const Text('Save workshop')),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: Theme.of(context).textTheme.labelMedium),
  );
}
