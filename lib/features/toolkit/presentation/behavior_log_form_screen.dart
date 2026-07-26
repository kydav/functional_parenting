import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/models/behavior_log.dart';
import 'package:functional_parenting/core/providers/toolkit_provider.dart';
import 'package:functional_parenting/core/services/analytics_service.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:functional_parenting/features/toolkit/presentation/behavior_log_options.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class BehaviorLogFormScreen extends HookConsumerWidget {
  final String? logId;
  const BehaviorLogFormScreen({this.logId, super.key});

  bool get isEditing => logId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(behaviorLogsProvider).value ?? const [];
    BehaviorLog? existing;
    for (final l in logs) {
      if (l.id == logId) existing = l;
    }

    final occurredAt = useState<DateTime>(
      existing?.occurredAt ?? DateTime.now(),
    );
    final setting = useState<String?>(existing?.setting.emptyToNull);
    final antecedent = useState<Set<String>>({...?existing?.antecedent});
    final behavior = useState<String?>(existing?.behavior.emptyToNull);
    final consequence = useState<Set<String>>({...?existing?.consequence});
    final trigger = useState<Set<String>>({...?existing?.trigger});
    final response = useState<Set<String>>({...?existing?.response});
    final outcome = useState<String?>(existing?.outcome.emptyToNull);
    final loaded = useRef(false);

    // The edit target streams in async — hydrate the fields once it arrives.
    if (isEditing && existing != null && !loaded.value) {
      loaded.value = true;
      occurredAt.value = existing.occurredAt;
      setting.value = existing.setting.emptyToNull;
      antecedent.value = {...existing.antecedent};
      behavior.value = existing.behavior.emptyToNull;
      consequence.value = {...existing.consequence};
      trigger.value = {...existing.trigger};
      response.value = {...existing.response};
      outcome.value = existing.outcome.emptyToNull;
    }

    Future<void> pickWhen() async {
      final date = await showDatePicker(
        context: context,
        initialDate: occurredAt.value,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now(),
      );
      if (date == null || !context.mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(occurredAt.value),
      );
      final t = time ?? TimeOfDay.fromDateTime(occurredAt.value);
      occurredAt.value = DateTime(
        date.year,
        date.month,
        date.day,
        t.hour,
        t.minute,
      );
    }

    final canSave = behavior.value != null;

    Future<void> save() async {
      if (!canSave) return;
      final log = BehaviorLog(
        id: logId ?? '',
        occurredAt: occurredAt.value,
        behavior: behavior.value ?? '',
        setting: setting.value ?? '',
        antecedent: antecedent.value.toList(),
        consequence: consequence.value.toList(),
        trigger: trigger.value.toList(),
        response: response.value.toList(),
        outcome: outcome.value ?? '',
      );
      await ref.read(toolkitRepositoryProvider).saveLog(log);
      AnalyticsService.instance.track('behavior_log_saved', {
        'edit': isEditing,
      });
      if (context.mounted) context.pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit log' : 'New log'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete',
              onPressed: () async {
                await ref.read(toolkitRepositoryProvider).deleteLog(logId!);
                if (context.mounted) context.pop();
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          _WhenField(value: occurredAt.value, onTap: pickWhen),
          const SizedBox(height: 20),
          _SingleSelect(
            label: 'Setting',
            hint: 'Where did it happen?',
            options: kSettingOptions,
            value: setting.value,
            onChanged: (v) => setting.value = v,
          ),
          _MultiSelect(
            label: 'Antecedent',
            hint: 'What happened right before the behavior?',
            options: kAntecedentOptions,
            selected: antecedent.value,
            onChanged: (v) => antecedent.value = v,
          ),
          _SingleSelect(
            label: 'Behavior',
            hint: 'What did your child do? (pick one)',
            options: kBehaviorOptions,
            value: behavior.value,
            onChanged: (v) => behavior.value = v,
          ),
          _MultiSelect(
            label: 'What happened afterward',
            hint:
                'What happened right after? Pick everything that applies — '
                'this is what points to the behavior’s function.',
            options: kConsequenceOptions,
            selected: consequence.value,
            onChanged: (v) => consequence.value = v,
          ),
          _MultiSelect(
            label: 'Possible added trigger',
            hint: 'Was anything else affecting the situation?',
            options: kTriggerOptions,
            selected: trigger.value,
            onChanged: (v) => trigger.value = v,
          ),
          _MultiSelect(
            label: 'How I responded',
            hint:
                'What actually happened, not what you think should have — '
                'honest tracking reveals the pattern.',
            options: kResponseOptions,
            selected: response.value,
            onChanged: (v) => response.value = v,
          ),
          _SingleSelect(
            label: 'Outcome',
            hint: 'What happened as a result?',
            options: kOutcomeOptions,
            value: outcome.value,
            onChanged: (v) => outcome.value = v,
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: canSave ? save : null,
            child: Text(isEditing ? 'Save changes' : 'Save log'),
          ),
          if (!canSave) ...[
            const SizedBox(height: 8),
            Text(
              'Pick a behavior to save.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

extension _EmptyToNull on String {
  String? get emptyToNull => trim().isEmpty ? null : this;
}

class _WhenField extends StatelessWidget {
  final DateTime value;
  final VoidCallback onTap;
  const _WhenField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('When', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.event_outlined, size: 18),
          label: Align(
            alignment: Alignment.centerLeft,
            child: Text(DateFormat('EEE, MMM d · h:mm a').format(value)),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            alignment: Alignment.centerLeft,
          ),
        ),
      ],
    );
  }
}

/// Section header shared by both selector types.
class _FieldLabel extends StatelessWidget {
  final String label;
  final String? hint;
  const _FieldLabel({required this.label, this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(
            hint!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 10),
      ],
    );
  }
}

/// Pick exactly one option (tap again to clear).
class _SingleSelect extends StatelessWidget {
  final String label;
  final String? hint;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  const _SingleSelect({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label: label, hint: hint),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in options)
                ChoiceChip(
                  label: Text(o),
                  selected: value == o,
                  showCheckmark: false,
                  onSelected: (sel) => onChanged(sel ? o : null),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pick any number of options.
class _MultiSelect extends StatelessWidget {
  final String label;
  final String? hint;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  const _MultiSelect({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label: label, hint: hint),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in options)
                FilterChip(
                  label: Text(o),
                  selected: selected.contains(o),
                  showCheckmark: true,
                  onSelected: (sel) {
                    final next = {...selected};
                    if (sel) {
                      next.add(o);
                    } else {
                      next.remove(o);
                    }
                    onChanged(next);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
