import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/engagement_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReflectionsScreen extends HookConsumerWidget {
  const ReflectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState(true);
    final reflections = useState<List<Reflection>>([]);

    useEffect(() {
      final future = ref.read(engagementProvider.notifier).getPastReflections();
      future.then((value) {
        reflections.value = value;
        loading.value = false;
      });
      return null;
    }, []);
    return Scaffold(
      appBar: AppBar(title: const Text('Reflections')),
      body: PageBody(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: loading.value
            ? const Center(child: CircularProgressIndicator())
            : reflections.value.isNotEmpty
            ? Column(
                children: reflections.value
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ReflectionCard(prompt: r.prompt, text: r.text),
                      ),
                    )
                    .toList(),
              )
            : const Center(child: Text('No reflections yet.')),
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  final String prompt;
  final String text;
  const _ReflectionCard({required this.prompt, required this.text});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prompt,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
