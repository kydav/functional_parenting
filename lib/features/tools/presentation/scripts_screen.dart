import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:functional_parenting/core/models/content.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/content_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';

class ScriptsScreen extends ConsumerWidget {
  const ScriptsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripts = ref.watch(scriptsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Scripts')),
      body: PageBody(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calm, ready-to-use words for common moments. Tap to see the reasoning behind each one.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ...scripts.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ScriptCard(script: s),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScriptCard extends StatelessWidget {
  final Script script;
  const _ScriptCard({required this.script});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kBlue.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: kNavy,
              size: 18,
            ),
          ),
          title: Text(
            script.situation,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            script.category,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colors.pageBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                script.script,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            if (script.why != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.psychology_alt_outlined,
                    size: 16,
                    color: kBlueDeep,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      script.why!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
