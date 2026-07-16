import 'package:flutter/material.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          const Eyebrow('Full toolkit', color: kSageDeep),
          const SizedBox(height: 10),
          const _LockedTile(
            title: 'ABC behavior tracker',
            subtitle: 'Log antecedent, behavior, consequence over time',
          ),
          const SizedBox(height: 12),
          const _LockedTile(
            title: 'Behavior goal worksheets',
            subtitle: 'Set and track a specific behavior goal',
          ),
          const SizedBox(height: 12),
          const _LockedTile(
            title: 'Reinforcement planner',
            subtitle:
                'Plan consequences and reinforcement that fit the function',
          ),
          const SizedBox(height: 12),
          const _LockedTile(
            title: 'Parent reset audio collection',
            subtitle: 'Guided audio to regulate on the go',
          ),
        ],
      ),
    );
  }
}

class _LockedTile extends StatelessWidget {
  final String title;
  final String subtitle;
  const _LockedTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ToolTile(
      icon: Icons.lock_outline_rounded,
      iconColor: kTextSecondary,
      title: title,
      subtitle: subtitle,
      trailing: const ProBadge(),
      onTap: () => context.go('/profile'),
    );
  }
}
