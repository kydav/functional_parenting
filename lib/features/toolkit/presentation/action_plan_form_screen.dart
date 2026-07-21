import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/models/action_plan.dart';
import 'package:functional_parenting/core/providers/toolkit_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class ActionPlanFormScreen extends HookConsumerWidget {
  final String? planId;
  const ActionPlanFormScreen({this.planId, super.key});

  bool get isEditing => planId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(actionPlansProvider).value ?? const [];
    ActionPlan? existing;
    for (final p in plans) {
      if (p.id == planId) existing = p;
    }

    final title = useTextEditingController(text: existing?.title ?? '');
    final goal = useTextEditingController(text: existing?.goal ?? '');
    final function = useTextEditingController(text: existing?.function ?? '');
    final prevention = useTextEditingController(
      text: existing?.prevention ?? '',
    );
    final replacement = useTextEditingController(
      text: existing?.replacement ?? '',
    );
    final reinforcement = useTextEditingController(
      text: existing?.reinforcement ?? '',
    );
    final response = useTextEditingController(text: existing?.response ?? '');
    final dataToTrack = useTextEditingController(
      text: existing?.dataToTrack ?? '',
    );
    final reviewDate = useState<DateTime?>(existing?.reviewDate);
    final loaded = useRef(false);

    if (isEditing && existing != null && !loaded.value) {
      loaded.value = true;
      title.text = existing.title;
      goal.text = existing.goal;
      function.text = existing.function;
      prevention.text = existing.prevention;
      replacement.text = existing.replacement;
      reinforcement.text = existing.reinforcement;
      response.text = existing.response;
      dataToTrack.text = existing.dataToTrack;
      reviewDate.value = existing.reviewDate;
    }

    Future<void> pickReview() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: reviewDate.value ?? now.add(const Duration(days: 14)),
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)),
      );
      if (picked != null) reviewDate.value = picked;
    }

    Future<void> save() async {
      if (title.text.trim().isEmpty) return;
      final plan = ActionPlan(
        id: planId ?? '',
        title: title.text.trim(),
        goal: goal.text.trim(),
        function: function.text.trim(),
        prevention: prevention.text.trim(),
        replacement: replacement.text.trim(),
        reinforcement: reinforcement.text.trim(),
        response: response.text.trim(),
        dataToTrack: dataToTrack.text.trim(),
        reviewDate: reviewDate.value,
        createdAt: existing?.createdAt ?? DateTime.now(),
      );
      final id = await ref.read(toolkitRepositoryProvider).savePlan(plan);
      if (!context.mounted) return;
      // After creating, drop straight into the one-page view.
      if (isEditing) {
        context.pop();
      } else {
        context.pushReplacement('/tools/plans/$id');
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit plan' : 'New plan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          _Field(
            label: 'Plan name',
            controller: title,
            hint: 'e.g. Calmer bedtime',
          ),
          _Field(
            label: 'Behavior goal',
            controller: goal,
            hint: 'What you want to see instead',
            maxLines: 2,
          ),
          _Field(
            label: 'Possible function',
            controller: function,
            hint: 'Attention, escape, a tangible, or regulation?',
            maxLines: 2,
          ),
          _Field(
            label: 'Prevention',
            controller: prevention,
            hint: 'What can you set up ahead of time to make it easier?',
            maxLines: 2,
          ),
          _Field(
            label: 'Replacement behavior',
            controller: replacement,
            hint: 'The skill to teach and reward instead',
            maxLines: 2,
          ),
          _Field(
            label: 'Reinforcement',
            controller: reinforcement,
            hint: 'How will you notice and reward the behavior you want?',
            maxLines: 2,
          ),
          _Field(
            label: 'When it happens, I will…',
            controller: response,
            hint: 'Your calm, consistent response',
            maxLines: 2,
          ),
          _Field(
            label: "What I'll track",
            controller: dataToTrack,
            hint: 'e.g. how often it happens each day',
            maxLines: 2,
          ),
          Text('Review date', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: pickReview,
            icon: const Icon(Icons.event_outlined, size: 18),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                reviewDate.value == null
                    ? 'Not set'
                    : DateFormat.yMMMMd().format(reviewDate.value!),
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              alignment: Alignment.centerLeft,
            ),
          ),
          if (reviewDate.value != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => reviewDate.value = null,
                child: const Text('Clear'),
              ),
            ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: save,
            child: Text(isEditing ? 'Save changes' : 'Create plan'),
          ),
        ],
      ),
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
