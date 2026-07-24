import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/toolkit_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:functional_parenting/features/tools/presentation/worksheets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders any [WorksheetTool] as a fill-in form and persists the parent's
/// latest answers. Text questions use multiline fields; choice questions use a
/// single-select list. Answers load from [worksheetResponseProvider] and save
/// back through the toolkit repository.
class WorksheetScreen extends HookConsumerWidget {
  final String worksheetId;
  const WorksheetScreen({required this.worksheetId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tool = worksheetById(worksheetId);
    if (tool == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Worksheet')),
        body: const Center(child: Text('Worksheet not found.')),
      );
    }

    final saved = ref.watch(worksheetResponseProvider(worksheetId));

    // One controller per text question; choice answers live in a value map.
    final controllers = useMemoized(
      () => {
        for (final q in tool.questions)
          if (q.input == WorksheetInput.text) q.key: TextEditingController(),
      },
      [tool.id],
    );
    final choices = useState<Map<String, String>>({});
    final hydrated = useRef(false);

    useEffect(() {
      return () {
        for (final c in controllers.values) {
          c.dispose();
        }
      };
    }, [controllers]);

    // Prefill once the saved answers arrive (post-build, so mutating choice
    // state is safe). Guarded so parent edits aren't clobbered by re-emits.
    useEffect(() {
      final answers = saved.value?.answers;
      if (answers != null && !hydrated.value) {
        hydrated.value = true;
        final initialChoices = <String, String>{};
        for (final q in tool.questions) {
          final value = answers[q.key] ?? '';
          if (q.input == WorksheetInput.text) {
            controllers[q.key]!.text = value;
          } else if (value.isNotEmpty) {
            initialChoices[q.key] = value;
          }
        }
        if (initialChoices.isNotEmpty) choices.value = initialChoices;
      }
      return null;
    }, [saved]);

    Future<void> save() async {
      final result = <String, String>{
        for (final q in tool.questions)
          q.key: q.input == WorksheetInput.text
              ? controllers[q.key]!.text.trim()
              : (choices.value[q.key] ?? ''),
      };
      await ref
          .read(toolkitRepositoryProvider)
          .saveWorksheet(worksheetId, result);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved')));
      context.pop();
    }

    return Scaffold(
      appBar: AppBar(title: Text(tool.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Eyebrow(tool.phaseEyebrow),
          const SizedBox(height: 10),
          Text(
            tool.intro,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          for (final q in tool.questions) ...[
            _QuestionCard(
              question: q,
              controller: controllers[q.key],
              selected: choices.value[q.key],
              onSelect: (value) =>
                  choices.value = {...choices.value, q.key: value},
            ),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 6),
          FilledButton(onPressed: save, child: const Text('Save')),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final WorksheetQuestion question;
  final TextEditingController? controller;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _QuestionCard({
    required this.question,
    required this.controller,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.prompt,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (question.examples != null) ...[
            const SizedBox(height: 6),
            Text(
              question.examples!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (question.input == WorksheetInput.text)
            TextField(
              controller: controller,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Write your answer…'),
            )
          else
            for (final option in question.options) ...[
              FunctionOptionTile(
                label: option.$1,
                description: option.$2,
                selected: selected == option.$1,
                onTap: () => onSelect(option.$1),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

/// A selectable option row (label + description) used for single-select
/// questions — the four behavior functions. Shared with the Action Plan form.
class FunctionOptionTile extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;
  const FunctionOptionTile({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? kBlue.withValues(alpha: 0.25)
              : context.colors.pageBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? kBlueDeep : context.colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: selected ? kBlueDeep : context.colors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
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
