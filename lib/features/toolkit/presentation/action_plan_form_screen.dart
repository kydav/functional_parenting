import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/models/action_plan.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/toolkit_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:functional_parenting/features/tools/presentation/worksheet_screen.dart';
import 'package:functional_parenting/features/tools/presentation/worksheets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Walks one challenging behavior through all five phases of the framework.
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
    final resetPlan = useTextEditingController(text: existing?.resetPlan ?? '');
    final goal = useTextEditingController(text: existing?.goal ?? '');
    final function = useState<String>(existing?.function ?? '');
    final structure = useTextEditingController(text: existing?.structure ?? '');
    final response = useTextEditingController(text: existing?.response ?? '');
    final loaded = useRef(false);

    if (isEditing && existing != null && !loaded.value) {
      loaded.value = true;
      title.text = existing.title;
      resetPlan.text = existing.resetPlan;
      goal.text = existing.goal;
      function.value = existing.function;
      structure.text = existing.structure;
      response.text = existing.response;
    }

    Future<void> save() async {
      if (title.text.trim().isEmpty) return;
      final plan = ActionPlan(
        id: planId ?? '',
        title: title.text.trim(),
        resetPlan: resetPlan.text.trim(),
        goal: goal.text.trim(),
        function: function.value,
        structure: structure.text.trim(),
        response: response.text.trim(),
        createdAt: existing?.createdAt ?? DateTime.now(),
      );
      final id = await ref.read(toolkitRepositoryProvider).savePlan(plan);
      if (!context.mounted) return;
      if (isEditing) {
        context.pop();
      } else {
        context.pushReplacement('/tools/plans/$id');
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit plan' : 'New plan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Text(
            'Choose one behavior that has been challenging and work through the '
            'five phases below.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _Field(
            label: 'The behavior you’re working on',
            controller: title,
            hint: 'e.g. Bedtime meltdowns',
          ),
          const SizedBox(height: 4),
          _StepCard(
            eyebrow: 'Phase 1 · Reset the Parent',
            prompt: 'What reaction would you like to practice instead?',
            examples:
                'e.g. “Instead of raising my voice, I’ll pause and lower my '
                'voice before responding.”',
            child: _Field(controller: resetPlan),
          ),
          _StepCard(
            eyebrow: 'Phase 2 · Define the Goal',
            prompt:
                'What skill do you want your child to develop instead of the '
                'current behavior?',
            examples:
                'e.g. asking for help appropriately, transitioning between '
                'activities, accepting limits, managing frustration',
            child: _Field(controller: goal),
          ),
          _StepCard(
            eyebrow: 'Phase 3 · Identify the Function',
            prompt: 'What might your child be trying to accomplish?',
            child: Column(
              children: [
                for (final option in kBehaviorFunctions) ...[
                  FunctionOptionTile(
                    label: option.$1,
                    description: option.$2,
                    selected: function.value == option.$1,
                    onTap: () => function.value = option.$1,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          _StepCard(
            eyebrow: 'Phase 4 · Build the Structure',
            prompt: 'What structure could make this situation easier?',
            examples:
                'e.g. clearer routines, predictable transitions, visual '
                'reminders, breaking tasks into smaller steps',
            child: _Field(controller: structure),
          ),
          _StepCard(
            eyebrow: 'Phase 5 · Respond With Purpose',
            prompt:
                'What intentional response will you practice when this happens '
                'again?',
            examples: 'e.g. “I see this is hard. Let’s start together.”',
            child: _Field(controller: response),
          ),
          const SizedBox(height: 6),
          FilledButton(
            onPressed: save,
            child: Text(isEditing ? 'Save changes' : 'Create plan'),
          ),
        ],
      ),
    );
  }
}

/// A phase step: eyebrow + prompt + optional example, wrapping its input.
class _StepCard extends StatelessWidget {
  final String eyebrow;
  final String prompt;
  final String? examples;
  final Widget child;
  const _StepCard({
    required this.eyebrow,
    required this.prompt,
    required this.child,
    this.examples,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(eyebrow),
            const SizedBox(height: 10),
            Text(
              prompt,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (examples != null) ...[
              const SizedBox(height: 6),
              Text(
                examples!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final String? hint;
  const _Field({required this.controller, this.label, this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          maxLines: label == null ? 3 : 1,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: hint ?? 'Write your answer…'),
        ),
      ],
    );
  }
}
