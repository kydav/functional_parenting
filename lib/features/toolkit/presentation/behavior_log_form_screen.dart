import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/models/behavior_log.dart';
import 'package:functional_parenting/core/providers/toolkit_provider.dart';
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
    final setting = useTextEditingController(text: existing?.setting ?? '');
    final antecedent = useTextEditingController(
      text: existing?.antecedent ?? '',
    );
    final behavior = useTextEditingController(text: existing?.behavior ?? '');
    final consequence = useTextEditingController(
      text: existing?.consequence ?? '',
    );
    final trigger = useTextEditingController(text: existing?.trigger ?? '');
    final response = useTextEditingController(text: existing?.response ?? '');
    final outcome = useTextEditingController(text: existing?.outcome ?? '');
    final loaded = useRef(false);

    if (isEditing && existing != null && !loaded.value) {
      loaded.value = true;
      occurredAt.value = existing.occurredAt;
      setting.text = existing.setting;
      antecedent.text = existing.antecedent;
      behavior.text = existing.behavior;
      consequence.text = existing.consequence;
      trigger.text = existing.trigger;
      response.text = existing.response;
      outcome.text = existing.outcome;
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

    Future<void> save() async {
      if (behavior.text.trim().isEmpty) return;
      final log = BehaviorLog(
        id: logId ?? '',
        occurredAt: occurredAt.value,
        behavior: behavior.text.trim(),
        setting: setting.text.trim(),
        antecedent: antecedent.text.trim(),
        consequence: consequence.text.trim(),
        trigger: trigger.text.trim(),
        response: response.text.trim(),
        outcome: outcome.text.trim(),
      );
      await ref.read(toolkitRepositoryProvider).saveLog(log);
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
          const SizedBox(height: 14),
          _Field(
            label: 'Setting',
            controller: setting,
            hint: 'Where were you? e.g. home, dinner table',
          ),
          _Field(
            label: 'Antecedent — what happened just before',
            controller: antecedent,
            hint: 'The request, transition, or trigger',
            maxLines: 2,
          ),
          _Field(
            label: 'Behavior',
            controller: behavior,
            hint: 'What your child did',
            maxLines: 2,
          ),
          _Field(
            label: 'Consequence — what happened right after',
            controller: consequence,
            maxLines: 2,
          ),
          _Field(
            label: 'Possible trigger',
            controller: trigger,
            hint: 'Tired, hungry, overstimulated…',
          ),
          _Field(label: 'How you responded', controller: response, maxLines: 2),
          _Field(label: 'Outcome', controller: outcome, maxLines: 2),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: save,
            child: Text(isEditing ? 'Save changes' : 'Save log'),
          ),
        ],
      ),
    );
  }
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

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}
