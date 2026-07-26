import 'package:flutter/material.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/pro_provider.dart';
import 'package:functional_parenting/core/services/analytics_service.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:functional_parenting/features/tools/presentation/worksheets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void _openTool(BuildContext context, String tool, String route) {
  AnalyticsService.instance.track('tool_open', {'tool': tool});
  context.go(route);
}

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proProvider);

    return PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            'Tools',
            subtitle: 'Practical help for the moments that matter.',
          ),
          const SizedBox(height: 24),

          // 1. Quick, free help for a behavior happening right now.
          const _GroupHeader(
            'In the moment',
            'Fast help while a behavior is happening — free to use.',
          ),
          const SizedBox(height: 14),
          ToolTile(
            icon: Icons.alt_route_rounded,
            iconColor: kBlueDeep,
            title: 'What should I do?',
            subtitle: 'Guided decisions for a behavior happening right now',
            onTap: () => _openTool(context, 'decide', '/tools/decide'),
          ),
          const SizedBox(height: 12),
          ToolTile(
            icon: Icons.chat_bubble_outline_rounded,
            iconColor: kSageDeep,
            title: 'Scripts library',
            subtitle: 'Exact words for tough situations',
            onTap: () => _openTool(context, 'scripts', '/tools/scripts'),
          ),
          const SizedBox(height: 12),
          ToolTile(
            icon: Icons.insights_rounded,
            iconColor: kSuccessGreen,
            title: 'Behavior-pattern check',
            subtitle: 'A quick read on what might be driving the behavior',
            onTap: () => _openTool(context, 'assessment', '/tools/assessment'),
          ),

          const SizedBox(height: 32),

          // 2. The four phase worksheets, as one guided sequence.
          const _GroupHeader(
            'Work the framework',
            'A guided worksheet for each phase of the Functional Parenting '
                'Framework.',
          ),
          const SizedBox(height: 16),
          for (final w in kWorksheets) ...[
            Eyebrow(w.phaseEyebrow),
            const SizedBox(height: 8),
            _ProTile(
              isPro: isPro,
              icon: w.icon,
              iconColor: w.iconColor,
              title: w.title,
              subtitle: w.subtitle,
              route: '/tools/worksheet/${w.id}',
            ),
            if (w.id != kWorksheets.last.id) const SizedBox(height: 16),
          ],

          const SizedBox(height: 32),

          // 3. Longer-running tools you return to over time.
          const _GroupHeader(
            'Ongoing toolkit',
            'Track patterns, make plans, and look things up over time.',
          ),
          const SizedBox(height: 14),
          _ProTile(
            isPro: isPro,
            icon: Icons.checklist_rounded,
            iconColor: kBlueDeep,
            title: 'Behavior tracker (ABC)',
            subtitle: 'Log antecedent, behavior, and consequence over time',
            route: '/tools/tracker',
          ),
          const SizedBox(height: 12),
          _ProTile(
            isPro: isPro,
            icon: Icons.description_outlined,
            iconColor: kSageDeep,
            title: 'Parenting plans',
            subtitle: 'Build a one-page Parenting Plan',
            route: '/tools/plans',
          ),
          const SizedBox(height: 12),
          _ProTile(
            isPro: isPro,
            icon: Icons.menu_book_rounded,
            iconColor: kSuccessGreen,
            title: 'Behavior-function guide',
            subtitle: 'Plain-language reference for the four functions',
            route: '/tools/guide',
          ),
        ],
      ),
    );
  }
}

/// Consistent header for each tool group: a title with a one-line description.
class _GroupHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _GroupHeader(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
        ),
      ],
    );
  }
}

class _ProTile extends StatelessWidget {
  final bool isPro;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? route;
  const _ProTile({
    required this.isPro,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = isPro && route != null;
    return ToolTile(
      icon: unlocked ? icon : Icons.lock_outline_rounded,
      iconColor: unlocked ? iconColor : context.colors.textSecondary,
      title: title,
      subtitle: subtitle,
      trailing: unlocked ? null : const ProBadge(),
      onTap: () {
        if (unlocked) {
          AnalyticsService.instance.track('tool_open', {'tool': title});
          context.push(route!);
        } else {
          AnalyticsService.instance.track('paywall_from_tool', {'tool': title});
          context.push('/paywall');
        }
      },
    );
  }
}
