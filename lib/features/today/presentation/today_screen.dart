import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';
import 'package:functional_parenting/core/providers/content_provider.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(authNotifierProvider).userName;
    final tip = ref.watch(dailyTipProvider);
    final challenge = ref.watch(dailyChallengeProvider);
    final reflection = ref.watch(dailyReflectionProvider);

    return PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: kTextSecondary),
          ),
          Text(
            'Hi ${_firstName(name)} 👋',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 20),

          // Reset Right Now — the emergency regulation button.
          SoftCard(
            color: kNavy,
            onTap: () => context.push('/reset'),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: kBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.self_improvement_rounded,
                    color: kNavy,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reset Right Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'A 60-second reset for a heated moment',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white70),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Eyebrow("Today's tip", icon: Icons.lightbulb_outline),
          const SizedBox(height: 8),
          SoftCard(
            color: const Color(0xFFF3F6F8),
            child: Text(
              tip.text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: 20),

          const Eyebrow(
            "Today's challenge",
            icon: Icons.flag_outlined,
            color: kSageDeep,
          ),
          const SizedBox(height: 8),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  challenge.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Nice — challenge marked done for today.',
                              ),
                            ),
                          ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Mark done'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Eyebrow(
            'Daily reflection',
            icon: Icons.edit_note_rounded,
          ),
          const SizedBox(height: 8),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reflection.prompt,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                const TextField(
                  maxLines: 3,
                  decoration: InputDecoration(hintText: 'Take a moment…'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ToolTile(
            icon: Icons.alt_route_rounded,
            iconColor: kBlueDeep,
            title: 'What should I do?',
            subtitle: 'Answer a few questions for in-the-moment guidance',
            onTap: () => context.go('/tools/decide'),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _firstName(String name) => name.trim().split(' ').first;
}
