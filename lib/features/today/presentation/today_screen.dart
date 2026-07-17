import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_parenting/core/presentation/widgets.dart';
import 'package:functional_parenting/core/providers/auth_provider.dart';
import 'package:functional_parenting/core/providers/content_provider.dart';
import 'package:functional_parenting/core/providers/engagement_provider.dart';
import 'package:functional_parenting/core/services/notification_service.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TodayScreen extends HookConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(authNotifierProvider).userName;
    final tip = ref.watch(dailyTipProvider);
    final challenge = ref.watch(dailyChallengeProvider);
    final reflection = ref.watch(dailyReflectionProvider);
    final engagement = ref.watch(engagementProvider);

    final reflectionCtrl = useTextEditingController(
      text: engagement.reflectionToday,
    );

    // Contextually request notification permission once we're in the app (the
    // toggles default on). Idempotent — iOS/Android won't re-prompt after the
    // first decision; if granted we (re)apply the saved schedules.
    useEffect(() {
      Future.microtask(() async {
        final settings = ref.read(notificationSettingsProvider);
        if (!settings.tipEnabled && !settings.challengeEnabled) return;
        if (await NotificationService.instance.requestPermission()) {
          await ref.read(notificationSettingsProvider.notifier).applyOnLaunch();
        }
      });
      return null;
    }, const []);

    return PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    Text(
                      'Hi ${_firstName(name)} 👋',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
              if (engagement.streak > 0) _StreakChip(streak: engagement.streak),
            ],
          ),
          const SizedBox(height: 20),

          // Reset Right Now — the emergency regulation button.
          SoftCard(
            color: context.colors.brandFill,
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
            color: context.colors.surfaceAlt,
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
                    if (engagement.challengeDoneToday)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: kSuccessGreen,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => ref
                            .read(engagementProvider.notifier)
                            .setChallengeDone(done: false),
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Done today'),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.successNotification();
                          ref
                              .read(engagementProvider.notifier)
                              .setChallengeDone(done: true);
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Mark done'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Eyebrow('Daily reflection', icon: Icons.edit_note_rounded),
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
                if (engagement.reflectionToday.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: kSuccessGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Saved',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: kSuccessGreen),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            useRootNavigator: true,
                            context: context,
                            builder: (context) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      reflection.prompt,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: reflectionCtrl,
                                      maxLines: 3,
                                      decoration: const InputDecoration(
                                        hintText: 'Take a moment…',
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        HapticFeedback.successNotification();
                                        ref
                                            .read(engagementProvider.notifier)
                                            .saveReflection(
                                              reflection.prompt,
                                              reflectionCtrl.text,
                                            );
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(
                                        Icons.check_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Save'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.edit_rounded, size: 18),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: reflectionCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Take a moment…',
                        ),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.successNotification();
                          ref
                              .read(engagementProvider.notifier)
                              .saveReflection(
                                reflection.prompt,
                                reflectionCtrl.text,
                              );
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Save'),
                      ),
                    ],
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

class _StreakChip extends StatelessWidget {
  final int streak;
  const _StreakChip({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: kSage.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '🔥 $streak-day streak',
        style: const TextStyle(
          color: kNavy,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
