import 'package:flutter/material.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/pro_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
          const SizedBox(height: 20),

          const Eyebrow('Free tools'),
          const SizedBox(height: 10),
          ToolTile(
            icon: Icons.alt_route_rounded,
            iconColor: kBlueDeep,
            title: 'What should I do?',
            subtitle: 'Guided decisions for a behavior happening right now',
            onTap: () => context.go('/tools/decide'),
          ),
          const SizedBox(height: 12),
          ToolTile(
            icon: Icons.chat_bubble_outline_rounded,
            iconColor: kSageDeep,
            title: 'Scripts library',
            subtitle: 'Exact words for tough situations',
            onTap: () => context.go('/tools/scripts'),
          ),
          const SizedBox(height: 12),
          ToolTile(
            icon: Icons.insights_rounded,
            iconColor: kSuccessGreen,
            title: 'Behavior-pattern check',
            subtitle: 'A quick read on what might be driving the behavior',
            onTap: () => context.go('/tools/assessment'),
          ),

          const SizedBox(height: 28),
          const Eyebrow('Starter Toolkit', color: kSageDeep),
          const SizedBox(height: 10),
          _ProTile(
            isPro: isPro,
            icon: Icons.checklist_rounded,
            iconColor: kBlueDeep,
            title: 'Behavior tracker',
            subtitle: 'Log antecedent, behavior, and consequence over time',
            route: '/tools/tracker',
          ),
          const SizedBox(height: 12),
          _ProTile(
            isPro: isPro,
            icon: Icons.description_outlined,
            iconColor: kSageDeep,
            title: 'Action plans',
            subtitle: 'Build a one-page Family Action Plan',
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
          const SizedBox(height: 12),
          _ProTile(
            isPro: isPro,
            icon: Icons.self_improvement_rounded,
            iconColor: kWarmAmber,
            title: 'Parent reset audio',
            subtitle: 'Guided audio to regulate on the go',
            route: null, // not built yet — sends to the toolkit
          ),
        ],
      ),
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
      onTap: () => unlocked ? context.push(route!) : context.push('/paywall'),
    );
  }
}
